#!/bin/bash
set -e

# Restore the database if it does not already exist.
if [ -f /database/chat.db ]; then
	echo "Database already exists, skipping restore"
else
	echo "No database found, restoring from replica (s3://${BUCKET_NAME}/chat.db) if exists"
	litestream restore -if-replica-exists -o database/chat.db "s3://${BUCKET_NAME}/chat.db"
fi

# Run litestream with your app as the subprocess.
exec litestream replicate -exec "/usr/local/bin/chat-app -dsn database/chat.db"