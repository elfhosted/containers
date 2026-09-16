#!/bin/sh
# Prepares /config for TREK, then execs the command as the current user (568).
#
# Replaces the root-only part of upstream's CMD (chown + gosu). Nothing here
# needs privileges: /config is expected to be writable by 568 already.
set -eu

if [ ! -w /config ]; then
  echo "FATAL: /config is not writable by uid $(id -u). Mount a volume owned by 568:568 at /config." >&2
  exit 1
fi

# /app/data and /app/uploads are symlinks into /config. Upstream pre-creates
# these subdirs in its image; a missing one surfaced as EACCES on first upload
# (upstream #1762), so they are created on every start. tmp is the server's
# global scratch dir; logs holds trek.log.
mkdir -p \
  /config/data/logs \
  /config/data/tmp \
  /config/uploads/files \
  /config/uploads/covers \
  /config/uploads/avatars \
  /config/uploads/photos \
  /config/uploads/journey \
  /config/uploads/places

# Upstream's preflight: fail loudly if the app itself is missing.
if [ ! -f /app/server/dist/index.js ] || [ ! -d /app/node_modules/tsconfig-paths ]; then
  echo "FATAL: TREK application files are missing from the image. Do not mount a volume over /app." >&2
  exit 1
fi

cd /app/server
exec "$@"
