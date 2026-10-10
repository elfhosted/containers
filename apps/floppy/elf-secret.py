"""Keep Floppy's per-instance SECRET in a one-row SQLite file, mirrored to a file.

Usage: python elf-secret.py STORE KEY_FILE

SECRET signs sessions and CSRF tokens and is the key Floppy encrypts stored
provider credentials and integration tokens with. Upstream generates one only
when /.dockerenv exists (it does not under Kubernetes) and otherwise refuses to
start, so elf-entrypoint.sh calls this before anything imports Django.

STORE (a tiny SQLite database) is authoritative. It exists so the chart's daily
backup sidecar, whose sqlite strategy takes online .backup copies of .sqlite3
files only, carries the key alongside db.sqlite3: a self-service restore then
brings back a key that can still decrypt the restored database, instead of the
fresh one generated after a reset.

KEY_FILE is what Floppy actually reads (the image sets SECRET_FILE to it), so
`kubectl exec` management commands see the same key as the running app. It is
rewritten from STORE on every start, so a restored STORE always wins.

Precedence when STORE has no key yet: an existing KEY_FILE (upstream keeps its
generated key at FLOPPY_DATA_DIR/secret_key, so an upstream db/ directory
dropped into /config keeps its key), else a new random key.
"""

import os
import secrets
import sqlite3
import sys
from pathlib import Path


def read_store(store):
    with sqlite3.connect(store) as con:
        con.execute(
            "CREATE TABLE IF NOT EXISTS secret ("
            " id INTEGER PRIMARY KEY CHECK (id = 1),"
            " value TEXT NOT NULL)",
        )
        row = con.execute("SELECT value FROM secret WHERE id = 1").fetchone()
    return row[0] if row and row[0] else None


def write_store(store, value):
    with sqlite3.connect(store) as con:
        con.execute("INSERT OR REPLACE INTO secret (id, value) VALUES (1, ?)", (value,))


def main(store, key_file):
    os.umask(0o077)
    store = Path(store)
    key_file = Path(key_file)

    value = read_store(store)
    if value is None:
        existing = key_file.read_text(encoding="utf-8").strip() if key_file.is_file() else ""
        if existing:
            value = existing
            print(f"[elf-secret] keeping the existing key from {key_file}", file=sys.stderr)
        else:
            value = secrets.token_urlsafe(50)
            print("[elf-secret] generated a new per-instance key", file=sys.stderr)
        write_store(store, value)

    current = key_file.read_text(encoding="utf-8").strip() if key_file.is_file() else None
    if current != value:
        tmp = key_file.with_name(f".{key_file.name}.tmp")
        tmp.write_text(value, encoding="utf-8")
        tmp.replace(key_file)
        if current:
            print(f"[elf-secret] {key_file} replaced from {store}", file=sys.stderr)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
