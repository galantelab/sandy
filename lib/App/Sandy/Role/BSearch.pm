package App::Sandy::Role::BSearch;
# ABSTRACT: Binary search role

use App::Sandy::Base 'role';

our $VERSION = '0.22'; # VERSION

sub with_bsearch {
	my ($self, $key, $base, $nmemb, $func) = @_;
	return $self->_bsearch($key, $base, 0, $nmemb - 1, $func);
}

sub _bsearch {
	my ($self, $key1, $base, $start, $end, $func) = @_;

	if ($start > $end) {
		# Not found!
		return;
	}

	my $index = int(($start + $end) / 2);
	my $key2 = $base->[$index];

	# $key1 <=> $key2
	my $rc = $func->($key1, $key2);

	if ($rc > 0) {
		return $self->_bsearch($key1, $base, $index + 1, $end, $func);
	} elsif ($rc < 0) {
		return $self->_bsearch($key1, $base, $start, $index - 1, $func);
	} else {
		return $index;
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::BSearch - Binary search role

=head1 VERSION

version 0.22

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
