package App::SimulateReads::Role::ParseArgv;
# ABSTRACT: Getopt::Long wrapper.

use App::SimulateReads::Base 'role';
use Getopt::Long 'GetOptionsFromArray';

our $VERSION = '0.10'; # VERSION

sub parser {
	my ($self, $argv, @opt_spec) = @_;
	my @argv = @{ $argv };
	my %opts;

	Getopt::Long::Configure('gnu_getopt');

	GetOptionsFromArray(
		\@argv,
		\%opts,
		@opt_spec
	) or die "Error parsing command-line arguments\n";
	
	return (\%opts, \@argv);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Role::ParseArgv - Getopt::Long wrapper.

=head1 VERSION

version 0.10

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
