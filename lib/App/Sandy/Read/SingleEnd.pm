package App::Sandy::Read::SingleEnd;
# ABSTRACT: App::Sandy::Read subclass for simulate single-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::Read';

our $VERSION = '0.25'; # VERSION

sub gen_read {
	my ($self, $ptable, $ptable_size, $read_size, $is_leader, $rng, $blacklist) = @_;

	if ($ptable_size < $read_size) {
		croak sprintf "ptable_size (%d) must be greater or equal to read_size (%d)"
			=> $ptable_size, $read_size;
	}

	my ($read_ref, $attr) = $self->subseq_rand_ptable($ptable,
		$ptable_size, $read_size, $read_size, $rng, $blacklist);

	unless ($is_leader) {
		$self->reverse_complement($read_ref);
	}

	$attr->{error} = $self->insert_sequencing_error($read_ref, $read_size, $rng);

	return ($read_ref, $attr);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Read::SingleEnd - App::Sandy::Read subclass for simulate single-end reads.

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
