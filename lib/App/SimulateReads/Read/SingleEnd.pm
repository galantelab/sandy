package App::SimulateReads::Read::SingleEnd;
# ABSTRACT: App::SimulateReads::Read subclass for simulate single-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Read';

# VERSION

sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;

	if ($seq_size < $self->read_size) {
		croak sprintf "seq_size (%d) must be greater or equal to read_size (%d)\n"
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
