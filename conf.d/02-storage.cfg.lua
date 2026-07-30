-- Storage: SQLite in /app/data (Cloudron's backed-up writable volume).
-- DB_* are overridable via env if the operator later moves to Postgres/MySQL.

default_storage = "sql"

sql = {
	driver = os.getenv("DB_DRIVER") or "SQLite3";
	database = os.getenv("DB_DATABASE") or "prosody.sqlite";
	host = os.getenv("DB_HOST");
	port = os.getenv("DB_PORT");
	username = os.getenv("DB_USERNAME");
	password = os.getenv("DB_PASSWORD");
}

-- Keep MAM (message archive) in the SQL store.
archive_store = "archive2"
storage = {
	archive2 = "sql";
}

-- How long to keep archived messages (XEP-0313).
archive_expires_after = "1y"

http_max_content_size = tonumber(os.getenv("HTTP_MAX_CONTENT_SIZE")) or 10 * 1024 * 1024
