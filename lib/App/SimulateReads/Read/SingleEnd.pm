package App::SimulateReads::Read::SingleEnd;
# ABSTRACT: App::SimulateReads::Read subclass for simulate single-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Read';

our $VERSION = '0.16'; # VERSION

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
	$self->insert_sequencing_error($read_ref);

	return ($read_ref, $read_pos);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Read::SingleEnd - App::SimulateReads::Read subclass for simulate single-end reads.

=head1 VERSION

version 0.16

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
