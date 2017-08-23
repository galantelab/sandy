PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS "sequencing_system" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	UNIQUE ("name")
);

CREATE TABLE IF NOT EXISTS "quality" (
	"id" INTEGER PRIMARY KEY,
	"sequencing_system_id" INTEGER NOT NULL,
	"source" TEXT DEFAULT "not defined",
	"is_user_provided" INTEGER DEFAULT 1,
	"size" INTEGER NOT NULL,
	"deepth" INTEGER NOT NULL,
	"matrix" BLOB NOT NULL,
	UNIQUE ("sequencing_system_id", "size"),
	FOREIGN KEY ("sequencing_system_id") REFERENCES "sequencing_system"("id") ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);
