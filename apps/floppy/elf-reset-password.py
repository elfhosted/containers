"""Set a Floppy account's password from FLOPPY_RESET_PASSWORD at startup.

FLOPPY_RESET_PASSWORD="<username>:<new password>" (split on the first colon;
Django usernames cannot contain one). Run by elf-entrypoint.sh after
migrations and before any app process starts; the entrypoint unsets the
variable afterwards, so nothing it starts inherits the password.

Applied once per value: a salted hash of the applied value is stored in the
database (table elfhosted_password_reset), in the same transaction as the new
password, and a later boot with the same value does nothing. Otherwise a
variable left in place would put the password back on every restart, undoing
any password the person sets afterwards. Keeping the receipt in the database
makes it commit with the password and travel with the database's backups.

The value also stays readable in /proc/1/environ (PID 1 keeps its starting
environment). Anything able to read that runs as this user and could already
rewrite the database, so it is not a new exposure; remove the variable once
the reset is done.

Never prints the password, and never fails the boot: every problem is a
warning and the app starts as usual.
"""

import os
import sys

RECEIPTS = "elfhosted_password_reset"


def log(msg):
    print(f"[elf-reset-password] {msg}", flush=True)


def main():
    raw = os.environ.get("FLOPPY_RESET_PASSWORD", "")
    if not raw:
        return 0
    username, sep, password = raw.partition(":")
    username = username.strip()
    if not sep or not username or not password:
        log("WARNING: FLOPPY_RESET_PASSWORD must look like <username>:<new password>; ignored")
        return 0

    # Run as a script from /usr/local/bin, so Python's path starts there; the
    # Django project is the working directory (the image's WORKDIR).
    sys.path.insert(0, os.getcwd())
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
    import django

    django.setup()
    from django.contrib.auth import get_user_model
    from django.contrib.auth.hashers import check_password, make_password
    from django.contrib.auth.password_validation import validate_password
    from django.core.exceptions import ValidationError
    from django.db import connection, transaction

    with connection.cursor() as cur:
        cur.execute(f"CREATE TABLE IF NOT EXISTS {RECEIPTS} (receipt VARCHAR(255) NOT NULL)")
        cur.execute(f"SELECT receipt FROM {RECEIPTS}")
        receipts = [row[0] for row in cur.fetchall()]
    if any(check_password(raw, r) for r in receipts):
        log("this reset was already applied; nothing to do (remove FLOPPY_RESET_PASSWORD)")
        return 0

    users = get_user_model().objects.filter(is_demo=False)
    user = users.filter(username=username).first()
    if user is None:
        matches = list(users.filter(username__iexact=username)[:2])
        user = matches[0] if len(matches) == 1 else None
    if user is None:
        # Never echo the supplied name: written the wrong way round
        # ("<password>:<username>") it would be the password.
        log("WARNING: no single account matches the username given; nothing changed")
        return 0

    try:
        validate_password(password, user=user)
    except ValidationError as exc:
        log(f"WARNING: new password for {user.username!r} rejected: {' '.join(exc.messages)}")
        return 0

    # Password and receipt commit together or not at all.
    with transaction.atomic():
        user.set_password(password)
        user.save(update_fields=["password"])
        with connection.cursor() as cur:
            cur.execute(f"INSERT INTO {RECEIPTS} (receipt) VALUES (%s)", [make_password(raw)])
    log(f"password for {user.username!r} reset; their other sessions are signed out")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:  # never block the boot
        log(f"WARNING: password reset failed ({exc.__class__.__name__}); nothing changed")
        sys.exit(0)
