package App::Sandy::Command::Quality;
# ABSTRACT: quality command class. Manage quality profile database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Quality;
use Text::ASCIITable;

extends 'App::Sandy::CLI::Command';

our $VERSION = '0.23'; # VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Quality',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report retrievedb/]
);

sub _build_db {
	return App::Sandy::DB::Handle::Quality->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::Sandy::Command::Quality::Add',
	remove  => 'App::Sandy::Command::Quality::Remove',
	restore => 'App::Sandy::Command::Quality::Restore',
	dump    => 'App::Sandy::Command::Quality::Dump'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;

	if (%$report_ref) {
		my $t1 = Text::ASCIITable->new;
		$t1->setCols('quality profile', 'mean', 'stdd', 'error', 'type', 'source', 'provider', 'date');

		for my $quality_profile (sort keys %$report_ref) {
			my $attr = $report_ref->{$quality_profile};
			$t1->addRow($quality_profile, $attr->{mean}, $attr->{stdd}, $attr->{error}, $attr->{type},
				$attr->{source}, $attr->{provider}, $attr->{date});
		}

		print $t1;
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Quality - quality command class. Manage quality profile database.

=head1 VERSION

version 0.23

=head1 SYNOPSIS

 sandy quality
 sandy quality [options]
 sandy quality <command>

 Options:
  -h, --help               brief help message
  -u, --man                full documentation
 
 Commands:
  add                      add a new quality profile to database
  dump                     dump a quality-profle from database
  remove                   remove an user quality profle from database
  restore                  restore the database

=head1 DESCRIPTION

Manage quality profile database.

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

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

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
