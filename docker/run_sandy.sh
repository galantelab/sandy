#!/usr/bin/env bash

set -e

DB_PATH="/usr/local/lib/perl5/vendor_perl/5.36.0/x86_64-linux-gnu/auto/share/dist/App-Sandy"
MOUNTED_DB_PATH="/sandy/db"
DB="db.sqlite3"

if [[ -d "$MOUNTED_DB_PATH" ]]; then
	if [[ ! -f "$MOUNTED_DB_PATH/$DB" ]]; then
		mv "$DB_PATH/$DB" "$MOUNTED_DB_PATH"
	fi
	ln -sf "$MOUNTED_DB_PATH/$DB" "$DB_PATH/$DB"
fi

exec sandy "$@"
