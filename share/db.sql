CREATE TABLE IF NOT EXISTS "quality_profile" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	"source" TEXT DEFAULT "not defined",
	"is_user_provided" INTEGER DEFAULT 1,
	"is_single_end" INTEGER NOT NULL,
	"mean" INTEGER NOT NULL,
	"stdd" INTEGER NOT NULL,
	"error" REAL NOT NULL,
	"deepth" INTEGER NOT NULL,
	"partil" INTEGER NOT NULL,
	"matrix" BLOB NOT NULL,
	"date" DATE DEFAULT CURRENT_DATE,
	UNIQUE ("name")
);

CREATE TABLE IF NOT EXISTS "expression_matrix" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	"source" TEXT DEFAULT "not defined",
	"is_user_provided" INTEGER DEFAULT 1,
	"matrix" BLOB NOT NULL,
	"date" DATE DEFAULT CURRENT_DATE,
	UNIQUE ("name")
);

CREATE TABLE IF NOT EXISTS "structural_variation" (
	"id" INTEGER PRIMARY KEY,
	"name" TEXT NOT NULL,
	"source" TEXT DEFAULT "not defined",
	"is_user_provided" INTEGER DEFAULT 1,
	"matrix" BLOB NOT NULL,
	"date" DATE DEFAULT CURRENT_DATE,
	UNIQUE ("name")
);
