package App::SimulateReads::DB;
# ABSTRACT: Singleton class to manage database

use App::SimulateReads::Base;
use App::SimulateReads::DB::Schema;
use MooseX::Singleton;
use Path::Class 'file';

# VERSION

has 'schema' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::DB::Schema',
	builder    => '_build_schema',
	lazy_build => 1,
);

sub _build_schema {
	my $self = shift;

	#  Hardcoded paths for database
	my $DB = 'db.sqlite3';
	my @DB_PATH = (
		file(__FILE__)->dir->parent->parent->parent->file('share'),
		file(__FILE__)->dir->parent->parent->file('auto', 'share', 'dist', 'App-SimulateReads')
	);

	# The chosen one
	my $db;

	for my $path (@DB_PATH) {
		# The chosen one
		my $file = file($path, $DB);
		if (-f $file) {
			$db = $file;
			last;
		}
	}

	croak "$DB not found in @DB_PATH" unless defined $db;

	return App::SimulateReads::DB::Schema->connect(
		"dbi:SQLite:$db",
		"",
		"",
		{
			RaiseError    => 1,
			PrintError    => 0,
			on_connect_do => 'PRAGMA foreign_keys = ON'
		}
	);
}
