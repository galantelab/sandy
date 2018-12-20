package App::Sandy::DB;
# ABSTRACT: Singleton class to manage database

use App::Sandy::Base;
use App::Sandy::DB::Schema;
use MooseX::Singleton;
use Path::Class 'file';

our $VERSION = '0.22'; # VERSION

has 'schema' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Schema',
	builder    => '_build_schema',
	lazy_build => 1,
);

sub _build_schema {
	my $self = shift;

	#  Hardcoded paths for database
	my $DB = 'db.sqlite3';
	my @DB_PATH = (
		file(__FILE__)->dir->parent->parent->parent->file('share', 'assets'),
		file(__FILE__)->dir->parent->parent->file('auto', 'share', 'dist', 'App-Sandy')
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

	die "$DB not found in @DB_PATH" unless defined $db;

	return App::Sandy::DB::Schema->connect(
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

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::DB - Singleton class to manage database

=head1 VERSION

version 0.22

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
