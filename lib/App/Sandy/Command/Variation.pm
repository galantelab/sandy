package App::Sandy::Command::Variation;
# ABSTRACT: variation command class. Manage structural variation database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Variation;
use Text::ASCIITable;

extends 'App::Sandy::CLI::Command';

our $VERSION = '0.22'; # VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Variation',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report retrievedb/]
);

sub _build_db {
	return App::Sandy::DB::Handle::Variation->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::Sandy::Command::Variation::Add',
	remove  => 'App::Sandy::Command::Variation::Remove',
	restore => 'App::Sandy::Command::Variation::Restore',
	dump    => 'App::Sandy::Command::Variation::Dump'
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
		$t1->setCols('structural variation', 'source', 'provider', 'date');

		for my $structural_variation (sort keys %$report_ref) {
			my $attr = $report_ref->{$structural_variation};
			$t1->addRow($structural_variation, $attr->{source}, $attr->{provider}, $attr->{date});
		}

		print $t1;
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Variation - variation command class. Manage structural variation database.

=head1 VERSION

version 0.22

=head1 SYNOPSIS

 sandy variation
 sandy variation [options]
 sandy variation <command>

 Options:
  -h, --help               brief help message
  -u, --man                full documentation

 Commands:
  add                      add a new structural variation to database
  dump                     dump structural variation from database
  remove                   remove an user structural variation from database
  restore                  restore the database

=head1 DESCRIPTION

Manage structural variation database.

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
