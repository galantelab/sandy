package App::Sandy::Role::Statistic;
# ABSTRACT: Basic statistics

use App::Sandy::Base 'role';
use List::Util 'sum';

our $VERSION = '0.23'; # VERSION

sub with_mean {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	return sum(@$vet) / scalar(@$vet);
}

sub with_variance {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	my $mean = $self->with_mean($vet);
	my @diff = map { ($_ - $mean) ** 2 } @$vet;

	return $self->with_mean(\@diff);
}

sub with_stdd {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	return sqrt $self->with_variance($vet);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::Statistic - Basic statistics

=head1 VERSION

version 0.23

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
