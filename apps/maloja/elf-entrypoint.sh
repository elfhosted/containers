#!/bin/sh
# Turn Maloja's MALOJA_FORCE_PASSWORD into a FIRST-RUN default.
#
# The problem this solves: upstream's force_password is not a seed, it is an
# override, and setup() re-applies it on EVERY start (maloja/setup.py). Set it
# in the chart and a tenant who changes their password in the web interface
# finds it reverted at the next pod reschedule, which can be days later and
# reads as an account being tampered with. Leave it unset instead and Maloja
# generates a random 32-character password and prints it to stdout exactly
# once, which is worse: on ElfHosted nobody sees the pod log, so the tenant is
# locked out of admin mode with no way back.
#
# So: apply the initial password only when Maloja has never stored one, and get
# out of the way afterwards.
#
# THE SENTINEL IS THE STORED USER, NOT THE EXISTENCE OF THE AUTH DATABASE.
# That distinction is the whole correctness argument here, and getting it wrong
# recreates the lockout this script exists to prevent:
#
#   doreah's AuthManager is constructed at IMPORT time of
#   maloja.pkg_global.conf, and constructing it creates auth/auth.sqlite
#   populated with doreah's factory user. That happens well before setup()
#   reaches auth.change_pw(). So a first start that is killed in between (OOM,
#   a node eviction, an unlucky rollout) leaves an auth.sqlite behind with no
#   real password in it. A file-existence check would then say "not a first
#   run" forever after, we would stop seeding, and Maloja would mint a random
#   password nobody can read. Verified: importing conf alone creates the file,
#   and still_has_factory_default_user() is still True afterwards.
#
# So ask doreah directly whether a real password has ever been stored. The
# probe costs about a second of startup and imports exactly what Maloja is
# about to import anyway.
#
# A tenant who sets MALOJA_FORCE_PASSWORD explicitly (through ElfBot) keeps
# upstream's behaviour verbatim, including the reset-every-boot part. That is
# the documented way back in after a forgotten password: set it, restart, sign
# in, unset it.
set -eu

DATA_DIR="${MALOJA_DATA_DIRECTORY:-/config}"
AUTH_DB="${DATA_DIR}/auth/auth.sqlite"

# 0 = never stored a real password (seed it)
# 1 = a real password is stored (leave it alone)
# 2 = could not tell
probe_needs_seeding() {
    /venv/bin/python -c '
import sys
try:
    from maloja.pkg_global.conf import auth
except Exception as exc:
    sys.stderr.write("probe: could not load maloja config: %r\n" % (exc,))
    sys.exit(2)
try:
    sys.exit(0 if auth.still_has_factory_default_user() else 1)
except Exception as exc:
    sys.stderr.write("probe: could not read auth state: %r\n" % (exc,))
    sys.exit(2)
'
}

if [ -n "${MALOJA_FORCE_PASSWORD:-}" ]; then
    echo "[elf-entrypoint] MALOJA_FORCE_PASSWORD is set explicitly; Maloja will reset the admin password to it on this and every start until it is unset."
else
    set +e
    probe_needs_seeding
    probe_rc=$?
    set -e

    case "${probe_rc}" in
        0)
            export MALOJA_FORCE_PASSWORD="${MALOJA_INITIAL_PASSWORD:-changemeelfie}"
            echo "[elf-entrypoint] No admin password has ever been stored; seeding the initial one. Change it in Maloja and it will stick."
            ;;
        1)
            echo "[elf-entrypoint] An admin password is already stored; leaving it alone."
            ;;
        *)
            # The probe could not answer, so fall back to the coarse check. It
            # is right in every case except the interrupted-first-start one
            # described above, and that case cannot be detected without the
            # probe that just failed. Seeding is the safer side of the coin: a
            # tenant whose password is reset to the documented default can
            # still get in and can still change it, whereas one whose password
            # was randomly generated and printed to an unread log cannot.
            if [ -f "${AUTH_DB}" ]; then
                echo "[elf-entrypoint] WARNING: could not read Maloja's auth state; ${AUTH_DB} exists, so assuming a password is already stored and leaving it alone."
            else
                export MALOJA_FORCE_PASSWORD="${MALOJA_INITIAL_PASSWORD:-changemeelfie}"
                echo "[elf-entrypoint] WARNING: could not read Maloja's auth state; no ${AUTH_DB} either, so treating this as a first start and seeding the initial password."
            fi
            ;;
    esac
fi

# tini is invoked here rather than being the ENTRYPOINT, so that an overridden
# command (CI's goss tests run `tail -f /dev/null`) still runs the logic above
# and still gets a working init.
exec /sbin/tini -- "$@"
