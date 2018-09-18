package App::Sandy::Role::RNorm;
# ABSTRACT: Random normal distribution

use App::Sandy::Base 'role';
use Math::Random 'random_normal';

our $VERSION = '0.21'; # VERSION

sub with_random_half_normal {
	my ($self, $mean, $stdd) = @_;
	return abs(int(random_normal(1, $mean, $stdd)));
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::RNorm - Random normal distribution

=head1 VERSION

version 0.21

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
