PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS "sequencing_system" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	UNIQUE ("name")
);

CREATE TABLE IF NOT EXISTS"quality" (
	"id" INTEGER PRIMARY KEY,
	"sequencing_system_id" INTEGER NOT NULL,
	"source" TEXT DEFAULT "Not defined",
	"size" INTEGER NOT NULL,
	"matrix" BLOB NOT NULL,
	UNIQUE ("sequencing_system_id", "size"),
	FOREIGN KEY ("sequencing_system_id") REFERENCES "sequencing_system"("id") ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);
