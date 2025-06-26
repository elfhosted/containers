#!/usr/bin/env python3
import os
import time
import signal
import re
import subprocess
import smtplib
import shlex
import sys
import traceback
from email.message import EmailMessage
from datetime import datetime

CHECK_INTERVAL = 90  # seconds
LOG_FILE = "/config/Library/Application Support/Plex Media Server/Logs/transcode-killer.log"

# SMTP configuration from environment variables
SMTP_HOST = os.environ.get("SMTP_HOST", "localhost")
SMTP_PORT = int(os.environ.get("SMTP_PORT", 25))
SMTP_USERNAME = os.environ.get("SMTP_USERNAME")
SMTP_PASSWORD = os.environ.get("SMTP_PASSWORD")
EMAIL_FROM = os.environ.get("EMAIL_FROM", "noreply@elfhosted.com")
EMAIL_TO = os.environ.get("EMAIL_TO")  # Must be set

# Add your regex-based exceptions here (e.g., allow audio-only transcodes)
EXCEPTIONS = [
    r"-codec:1\s+copy",  # audio is not being transcoded
]

def log(message):
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
    # Clean subject: reason + filename (truncated if needed)
    short_reason = reason.split('.')[0]
    short_filename = filename if len(filename) <= 60 else filename[:57] + "..."
    subject = f"[ElfHosted] Transcode Blocked: {short_reason} ({short_filename})"

    body = f"""\
Hi there,

Just a quick heads-up — a transcoding process on your media server was automatically stopped to help prevent system resource overload.

Here's what happened:

• **File**: {filename}
• **Why it was blocked**: {reason}
• **Command**: {command}
• **Full command line**:
{cmdline}

We block certain types of software-based or non-optimized transcodes to keep the system running smoothly for everyone. This includes:
- Transcodes without hardware acceleration (e.g., VA-API)
- 4K media being downscaled/transcoded
- Processes used for thumbnailing or audio fingerprinting

If this was unexpected or you believe it was blocked in error, feel free to reach out, at https://discord.elfhosted.com — we’re happy to help investigate or adjust the rules if needed.

Thanks for helping keep the system healthy! 🌱

- ElfHosted
"""

    msg = EmailMessage()
    msg.set_content(body)
    msg['Subject'] = subject
    msg['From'] = EMAIL_FROM
    msg['To'] = EMAIL_TO

    try:
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
    if re.search(r'-(?:c:v|codec:0)(?::\d+)?\s+copy', cmdline):
        return False, None
    if "-version" in cmdline:
        return False, None
    if "chromaprint" in cmdline:
        return True, "Audio fingerprinting (chromaprint) detected, bandwidth-wasteful, blocking"
    if "blackframe" in cmdline:
        return True, "Jellyfin chapter thumbnailling detected, bandwidth-wasteful, blocking"
    if not re.search(r'-(?:c:v|codec:0|map\s+0:v)', cmdline) and re.search(r'-(?:ac|ar|acodec)', cmdline):
        return False, None
    video_codec_match = re.search(r'-(?:c:v|codec:0)(?::\d+)?\s+(\S+)', cmdline)
    video_codec = video_codec_match.group(1).lower() if video_codec_match else None
    if video_codec == "copy":
        return False, None
    if re.search(r'-(?:c:s|scodec)\s+(ass|webvtt)', cmdline):
        return False, None
    if video_codec == "flac":
        return False, None
    if "vaapi" not in cmdline.lower() and re.search(r'-(?:c:v|codec:0)', cmdline) and video_codec != "copy":
        return True, "No VA-API involved, blocking software transcode"
    input_match = re.search(r'-i\s+(\S+)', cmdline)
    if input_match:
        input_path = input_match.group(1)
        if re.search(r'4k|2160', input_path, re.IGNORECASE):
            return True, f"Transcoding from 4K source ({input_path}) is not allowed"
    return False, None

def monitor():
    while True:
        for pid, command, cmdline in get_matching_processes():
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

                    # Extract input filename using shlex
                    try:
                        args = shlex.split(cmdline)
                        input_path = None
                        for i, arg in enumerate(args):
                            if arg == "-i" and i + 1 < len(args):
                                input_path = args[i + 1]
                                break
                        filename = os.path.basename(input_path) if input_path else "unknown"
                    except Exception as e:
                        log(f"Failed to parse input filename: {e}")
                        filename = "unknown"

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
