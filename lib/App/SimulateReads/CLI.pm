package App::SimulateReads::CLI;
# ABSTRACT: Base class for command line interface.

use App::SimulateReads::Base 'class';
use Path::Class 'file';

our $VERSION = '0.16'; # VERSION

has 'argv' => (
	is      => 'ro',
	isa     => 'ArrayRef',
	default => sub { \@ARGV }
);

has 'progname' => (
	is      => 'ro',
	isa     => 'Str',
	default => file($0)->basename
);

sub opt_spec {
	'help|h',
	'man|M'
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::CLI - Base class for command line interface.

=head1 VERSION

version 0.16

=head1 SYNOPSIS

 extends 'App::SimulateReads::CLI';

=head1 DESCRIPTION

This is the base class for CLI interface 

=head1 METHODS

=head2 argv

This mthod returns the \@ARGV

=head2 progname

This method returns the program name

=head2 opt_spec

This is the global options method. Child classes may
override it and provides more options by $self->super

=head1 SEE ALSO

=over 4

=item *

L<App::SimulateReads::CLI::App>

=item *

L<App::SimulateReads::CLI::Command>

=back

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
