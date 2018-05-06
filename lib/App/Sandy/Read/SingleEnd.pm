package App::Sandy::Read::SingleEnd;
# ABSTRACT: App::Sandy::Read subclass for simulate single-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::Read';

# VERSION

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
