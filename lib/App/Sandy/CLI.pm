package App::Sandy::CLI;
# ABSTRACT: Base class for command line interface.

use App::Sandy::Base 'class';
use Path::Class 'file';

our $VERSION = '0.22'; # VERSION

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
	'man|u'
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::CLI - Base class for command line interface.

=head1 VERSION

version 0.22

=head1 SYNOPSIS

 extends 'App::Sandy::CLI';

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

L<App::Sandy::CLI::App>

=item *

L<App::Sandy::CLI::Command>

=back

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
