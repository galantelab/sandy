package App::Sandy::RNG;
# ABSTRACT: Generates random numbers

use 5.018000;
use strict;
use warnings;

require Exporter;

our $VERSION = '0.25'; # VERSION

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ('all' => [ qw() ]);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

require XSLoader;
XSLoader::load('App::Sandy::RNG', $VERSION);

# Preloaded methods go here.

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::RNG - Generates random numbers

=head1 VERSION

version 0.25

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

Rafael Mercuri <rmercuri@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
