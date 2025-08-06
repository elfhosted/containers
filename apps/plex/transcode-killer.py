#!/usr/bin/env python3
import os
import time
import signal
import re
import shlex
import subprocess
import smtplib
import sys
import traceback
from email.message import EmailMessage
from datetime import datetime
from collections import deque

BLOCKED_RECENTLY = deque()  # stores tuples: (timestamp, filename)
BLOCK_RECHECK_WINDOW = 30   # seconds

CHECK_INTERVAL = 15  # seconds
LOG_FILE = "/config/Library/Application Support/Plex Media Server/Logs/transcode-killer.log"

# SMTP configuration from environment variables
SMTP_HOST = os.environ.get("SMTP_HOST", "localhost")
SMTP_PORT = int(os.environ.get("SMTP_PORT", 25))
SMTP_USERNAME = os.environ.get("SMTP_USERNAME")
SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD")
EMAIL_FROM = os.environ.get("EMAIL_FROM", "noreply@elfhosted.com")
EMAIL_TO = os.environ.get("EMAIL_TO")  # Must be set
DEBUG_LOGGING = os.environ.get("DEBUG_LOGGING", "false").lower() in ("1", "true", "yes")


# Add your regex-based exceptions here (e.g., allow audio-only transcodes)
EXCEPTIONS = [
    r"-codec:1\s+copy",  # audio is not being transcoded
]

def was_recently_blocked(filename):
    now = time.time()
    # Remove old entries
    while BLOCKED_RECENTLY and now - BLOCKED_RECENTLY[0][0] > BLOCK_RECHECK_WINDOW:
        BLOCKED_RECENTLY.popleft()
    # Check if filename was recently blocked
    return any(f == filename for _, f in BLOCKED_RECENTLY)

def log(message):
    if message.startswith("[DEBUG]") and not DEBUG_LOGGING:
        return  # Skip debug output unless enabled

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_line = f"{timestamp} {message}\n"
    with open(LOG_FILE, "a") as f:
        f.write(log_line)
    print(log_line, end="", file=sys.stdout, flush=True)

def process_is_alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False
    except Exception:
        return True  # Assume alive unless proven otherwise

def send_email(reason, pid, command, cmdline, filename):
    # Ensure we only use the file's basename (no directory path)
    filename = os.path.basename(filename)

    # Clean subject: reason + filename (truncated if needed)
    short_reason = reason.split('.')[0]
    short_filename = filename if len(filename) <= 60 else filename[:57] + "..."
    subject = f"[ElfHosted] Transcode Blocked: {short_reason} ({short_filename})"
    
    body = f"""\
Hi there,

Just a quick heads-up — a transcoding process on your media server was automatically stopped to help prevent system resource overload.

Here's what happened:

• File: {filename}
• Why it was blocked: {reason}

We block certain types of software-based or non-optimized transcodes to keep the system running smoothly for everyone. This includes:
- Transcodes without hardware acceleration (e.g., VA-API)
- 4K media being downscaled/transcoded
- Processes used for thumbnailing or audio fingerprinting

If this was unexpected or you believe it was blocked in error, feel free to reach out, at https://discord.elfhosted.com — we’re happy to help investigate or adjust if needed.

Thanks for helping keep the system healthy! 🌱

Here's the full process information:

---
{cmdline}
---

- ElfHosted
"""

    msg = EmailMessage()
    msg.set_content(body)
    msg['Subject'] = subject
    msg['From'] = EMAIL_FROM

    try:
        log(f"Sending email to {EMAIL_TO}")
        msg['To'] = EMAIL_TO.strip()
        if SMTP_USERNAME and SMTP_PASSWORD:
            with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
                server.starttls()
                server.login(SMTP_USERNAME, SMTP_PASSWORD)
                server.send_message(msg)
        else:
            with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
                server.send_message(msg)
        log("Email notification sent.")

    except Exception as e:
        log(f"Failed to send email: {e}")

def get_matching_processes():
    try:
        result = subprocess.run(["ps", "axo", "pid=,comm=,args="], capture_output=True, text=True, check=True)
        for line in result.stdout.strip().splitlines():
            try:
                pid_str, command, cmdline = re.split(r'\s+', line.strip(), maxsplit=2)
                pid = int(pid_str)
                if "ffmpeg" in command.lower() or "plex transcoder" in cmdline.lower():
                    yield pid, command, cmdline
            except ValueError:
                continue
    except Exception as e:
        log(f"Error reading processes: {e}")

def is_exception(cmdline):
    return any(re.search(pattern, cmdline) for pattern in EXCEPTIONS)

def is_video_transcode(cmdline):
    cmdline = ' '.join(cmdline.split())  # Normalize whitespace
    log(f"[DEBUG] is_video_transcode() input: {cmdline[:300]}")

    # Skip known exceptions
    if any(re.search(pattern, cmdline) for pattern in EXCEPTIONS):
        log("[DEBUG] Command matches exception pattern, skipping.")
        return False, "Matched exception"

    if re.search(r'/Metadata/.*(theme|agent|trailers?|extras?)', cmdline, re.IGNORECASE):
        return False, "Allowed: Plex metadata (theme/agent/trailer)"

    if "-version" in cmdline:
        return False, None

    if "chromaprint" in cmdline:
        return True, "Audio fingerprinting (chromaprint) detected. Bandwidth-wasteful, blocking"

    if "blackframe" in cmdline:
        return True, "Jellyfin chapter thumbnailling detected. Bandwidth-wasteful, blocking"

    # --- Detect all video codec assignments ---
    video_codecs = re.findall(r'-(?:c:v|codec:0)(?::\d+)?\s+(\S+)', cmdline)
    log(f"[DEBUG] Found video codec declarations: {video_codecs}")

    final_video_codec = video_codecs[-1].lower() if video_codecs else None
    log(f"[DEBUG] Final video codec used: {final_video_codec}")

    if final_video_codec == "copy":
        return False, "Allowed: video is being remuxed (copy)"

    if final_video_codec == "hevc":
        return True, "HEVC decode detected (CPU-intensive), blocking"

    if final_video_codec and not any(hw in cmdline.lower() for hw in ["vaapi", "nvenc", "nvdec", "cuda"]):
        return True, "No hardware acceleration (VAAPI/NVENC/NVDEC/CUDA) involved, blocking software transcode"

    # --- Block video transcode from 4K sources only ---
    input_match = re.search(r'-i\s+["\']?(.+?\.(?:mkv|mp4|avi|ts|mov))["\']?', cmdline, re.IGNORECASE)
    if input_match and final_video_codec != "copy":
        input_path = input_match.group(1).strip()
        if re.search(r'4k|2160|webdl-2160|uhd', input_path, re.IGNORECASE):
            return True, f"Transcoding from 4K source is not allowed. ({input_path})"

    return False, None



def monitor():
    while True:
        for pid, command, cmdline in get_matching_processes():

            # --- Extract filename BEFORE evaluation ---
            input_path = "unknown"
            filename = "unknown"
            try:
                input_match = re.search(r'-i\s+["\']?(.+?\.(?:mkv|mp4|avi|ts|mov))["\']?', cmdline, re.IGNORECASE)
                if input_match:
                    input_path = input_match.group(1).strip()
                    filename = os.path.basename(input_path)
            except Exception as e:
                log(f"Failed to extract filename from input: {e}")

            # --- Block fallback attempts for same file ---
            if was_recently_blocked(filename):
                log(f"Blocking fallback transcode for previously killed file: {filename}")
                try:
                    os.kill(pid, signal.SIGTERM)
                    time.sleep(2)
                    if process_is_alive(pid):
                        os.kill(pid, signal.SIGKILL)
                        log(f"SIGKILL fallback used on retry PID {pid} ({command})")
                except Exception as e:
                    log(f"Failed to terminate retry PID {pid}: {e}")
                continue

            # --- Evaluate for new kill decision ---
            should_kill, reason = is_video_transcode(cmdline)
            if should_kill and not is_exception(cmdline):
                try:
                    os.kill(pid, signal.SIGTERM)
                    log(f"Sent SIGTERM to PID {pid} ({command}) - {reason}")
                    time.sleep(2)
                    if process_is_alive(pid):
                        os.kill(pid, signal.SIGKILL)
                        log(f"SIGKILL fallback used on PID {pid} ({command})")

                    log_line = f"KILLED PID {pid} ({command}) - {reason} - {cmdline}"
                    log(log_line)
                    BLOCKED_RECENTLY.append((time.time(), filename))
                    send_email(reason, pid, command, cmdline, filename)

                except PermissionError:
                    log(f"Permission denied trying to terminate PID {pid}")
                except Exception as e:
                    log(f"Unexpected error handling PID {pid}: {e}")

        time.sleep(CHECK_INTERVAL)



if __name__ == "__main__":
    try:
        monitor()
    except Exception:
        log("Fatal error occurred:\n" + traceback.format_exc())
        sys.exit(1)
