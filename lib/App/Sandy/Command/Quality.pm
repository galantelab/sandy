package App::Sandy::Command::Quality;
# ABSTRACT: quality command class. Manage quality profile database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Quality;
use Text::SimpleTable::AutoWidth;

extends 'App::Sandy::CLI::Command';

our $VERSION = '0.18'; # VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Quality',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report/]
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
	restore => 'App::Sandy::Command::Quality::Restore'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;
	my $t1 = Text::SimpleTable::AutoWidth->new;

	$t1->captions(['quality profile', 'size', 'source', 'provider', 'date']);

	for my $quality_profile (sort keys %$report_ref) {
		my $attr = $report_ref->{$quality_profile};
		$t1->row($quality_profile, $attr->{size}, $attr->{source}, $attr->{provider}, $attr->{date});
	}

	print $t1->draw;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Quality - quality command class. Manage quality profile database.

=head1 VERSION

version 0.18

=head1 SYNOPSIS

 sandy quality
 sandy quality [options]
 sandy quality <command>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new quality profile to database
  remove                   remove an user quality profle from database
  restore                  restore the database

=head1 DESCRIPTION

Manage quality profile database.

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

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
