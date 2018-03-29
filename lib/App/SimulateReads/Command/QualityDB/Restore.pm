package App::SimulateReads::Command::QualityDB::Restore;
# ABSTRACT: qualitydb subcommand class. Restore database.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::QualityDB';

our $VERSION = '0.14'; # VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {}

sub execute {
	my ($self, $opts, $args) = @_;
	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;
	log_msg "Restoring quality database to vendor state ...";
	$self->restoredb;
	log_msg "Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Command::QualityDB::Restore - qualitydb subcommand class. Restore database.

=head1 VERSION

version 0.14

=head1 SYNOPSIS

 simulate_reads qualitydb restore

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
