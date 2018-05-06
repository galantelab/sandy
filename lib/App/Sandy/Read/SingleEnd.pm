package App::Sandy::Read::SingleEnd;
# ABSTRACT: App::Sandy::Read subclass for simulate single-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::Read';

our $VERSION = '0.18'; # VERSION

sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;

	if ($seq_size < $self->read_size) {
		die sprintf "seq_size (%d) must be greater or equal to read_size (%d)\n"
			=> $seq_size, $self->read_size;
	}

	my ($read_ref, $read_pos) = $self->subseq_rand($seq_ref, $seq_size, $self->read_size);

	unless ($is_leader) {
		$self->reverse_complement($read_ref);
	}

	$self->update_count_base($self->read_size);
	my $errors_a = $self->insert_sequencing_error($read_ref);

	return ($read_ref, $read_pos, $errors_a);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Read::SingleEnd - App::Sandy::Read subclass for simulate single-end reads.

=head1 VERSION

version 0.18

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

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
