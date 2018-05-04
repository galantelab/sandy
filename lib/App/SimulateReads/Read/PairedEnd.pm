package App::SimulateReads::Read::PairedEnd;
# ABSTRACT: App::SimulateReads::Read subclass for simulate paired-end reads.

use App::SimulateReads::Base 'class';
use Math::Random 'random_normal';

extends 'App::SimulateReads::Read';

# VERSION

use constant {
	NUM_TRIES => 1000
};

has 'fragment_mean' => (
	is       => 'ro',
	isa      => 'My:IntGt0',
	required => 1
);

has 'fragment_stdd' => (
	is       => 'ro',
	isa      => 'My:IntGe0',
	required => 1
);

sub BUILD {
	my $self = shift;
	unless (($self->fragment_mean - $self->fragment_stdd) >= $self->read_size) {
		die sprintf "fragment_mean (%d) minus fragment_stdd (%d) must be greater or equal to read_size (%d)\n"
			=> $self->fragment_mean,  $self->fragment_stdd, $self->read_size;
	}
}

sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;

	if ($seq_size < $self->fragment_mean) {
		die sprintf "seq_size (%d) must be greater or equal to fragment_mean (%d)\n"
			=> $seq_size, $self->fragment_mean;
	}

	my $fragment_size = 0;
	my $random_tries = 0;

	until (($fragment_size <= $seq_size) && ($fragment_size >= $self->read_size)) {
		# seq_size must be greater or equal to fragment_size and
		# fragment_size must be greater or equal to read_size
		# As fragment_size is randomly calculated, try out NUM_TRIES times
		if (++$random_tries > NUM_TRIES) {
			die sprintf
				"So many tries to calculate a fragment. the constraints were not met:\n" .
				"fragment_size <= seq_size (%d) and fragment_size >= read_size (%d)\n"
					=> $seq_size, $self->read_size;
		}

		$fragment_size = $self->_random_half_normal;
	}

	my ($fragment_ref, $fragment_pos) = $self->subseq_rand($seq_ref, $seq_size, $fragment_size);

	my $read1_ref = $self->subseq($fragment_ref, $fragment_size, $self->read_size, 0);
	$self->update_count_base($self->read_size);
	my $errors1_a = $self->insert_sequencing_error($read1_ref);

	my $read2_ref = $self->subseq($fragment_ref, $fragment_size, $self->read_size, $fragment_size - $self->read_size);
	$self->reverse_complement($read2_ref);
	$self->update_count_base($self->read_size);
	my $errors2_a = $self->insert_sequencing_error($read2_ref);

	return $is_leader
		? ($read1_ref, $errors1_a, $read2_ref, $errors2_a, $fragment_pos, $fragment_size)
		: ($read2_ref, $errors2_a, $read1_ref, $errors1_a, $fragment_pos, $fragment_size);
}

sub _random_half_normal {
	my $self = shift;
	return abs(int(random_normal(1, $self->fragment_mean, $self->fragment_stdd)));
}
