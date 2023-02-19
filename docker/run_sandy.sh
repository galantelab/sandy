#!/usr/bin/env bash

set -e

PERL_BASE="$(perl -V:'install(vendorarch)' \
	| perl -F= -lanE "say \$F[1] =~ s/[';]//rg")"

DB_PATH="$PERL_BASE/auto/share/dist/App-Sandy"
MOUNTED_DB_PATH="/sandy/db"
DB="db.sqlite3"

if [[ -d "$MOUNTED_DB_PATH" ]]; then
	if [[ ! -f "$MOUNTED_DB_PATH/$DB" ]]; then
		mv "$DB_PATH/$DB" "$MOUNTED_DB_PATH"
	fi
	ln -sf "$MOUNTED_DB_PATH/$DB" "$DB_PATH/$DB"
fi

exec sandy "$@"
