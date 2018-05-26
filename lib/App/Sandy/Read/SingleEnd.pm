package App::Sandy::Read::SingleEnd;
# ABSTRACT: App::Sandy::Read subclass for simulate single-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::Read';

# VERSION

sub gen_read {
	my ($self, $ptable, $ptable_size, $is_leader) = @_;

	if ($ptable_size < $self->read_size) {
		croak sprintf "ptable_size (%d) must be greater or equal to read_size (%d)"
			=> $ptable_size, $self->read_size;
	}

	my ($read_ref, $attr) = $self->subseq_rand_ptable($ptable, $ptable_size,
		$self->read_size);

	unless ($is_leader) {
		$self->reverse_complement($read_ref);
	}

	$self->update_count_base($self->read_size);
	$attr->{error} = $self->insert_sequencing_error($read_ref);

	return ($read_ref, $attr);
}
