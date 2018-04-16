package App::SimulateReads::Command::Quality::Remove;
# ABSTRACT: quality subcommand class. Remove a quality profile from database.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::Quality';

our $VERSION = '0.16'; # VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	my $quality_profile = shift @$args;

	if (not defined $quality_profile) {
		die "Missing quality-profile\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $quality_profile = shift @$args;

	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;

	log_msg ":: Attempting to remove $opts->{'quality-profile'}";
	$self->deletedb($quality_profile);
	log_msg ":: Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Command::Quality::Remove - quality subcommand class. Remove a quality profile from database.

=head1 VERSION

version 0.16

=head1 SYNOPSIS

 simulate_reads quality remove <quality-profile>

 Arguments:
  a quality-profile entry

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
