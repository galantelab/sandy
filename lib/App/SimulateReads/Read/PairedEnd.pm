package App::SimulateReads::Read::PairedEnd;
# ABSTRACT: App::SimulateReads::Read subclass for simulate paired-end reads.

use App::SimulateReads::Base 'class';
use Math::Random 'random_normal';

extends 'App::SimulateReads::Read';

use constant {
	NUM_TRIES => 1000
};

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'fragment_mean' => (is => 'ro', isa => 'My:IntGt0', required => 1);
has 'fragment_stdd' => (is => 'ro', isa => 'My:IntGe0', required => 1);

#===  CLASS METHOD  ============================================================
#        CLASS: Read::PairedEnd
#       METHOD: BUILD (Moose)
#   PARAMETERS: Void
#      RETURNS: Void
#  DESCRIPTION: Test if fragment_mean is greater or equal to read_size
#       THROWS: If fragment_mean is lesser than read_size, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub BUILD {
	my $self = shift;
	unless (($self->fragment_mean - $self->fragment_stdd) >= $self->read_size) {
		croak "fragment_mean (" . $self->fragment_mean . ") minus fragment_stdd (" . $self->fragment_stdd .
		      ") must be greater or equal to read_size (" . $self->read_size . ")\n";
	}
} ## --- end sub BUILD

#===  CLASS METHOD  ============================================================
#        CLASS: Read::PairedEnd
#       METHOD: gen_read
#   PARAMETERS: $seq_ref Ref Str, $seq_size Int > 0, $is_leader Bool
#      RETURNS: $read1_ref Ref Str, $read2_ref Ref Str, $fragment_pos Int >= 0,
#               $fragment_size Int > 0
#  DESCRIPTION: Generate paired-end read
#       THROWS: It complex, beacuse depending of the fragment_size, fragment_stdd
#               and read_size the method may raffle a fragment lesser than read_size.
#               So, the method gives NUM_TRIES chances to slice a fragment greater or
#               equal to read_size. If it fails, throws an exception.
#     COMMENTS: The fragment_size must be inside a normal distribution
#     SEE ALSO: n/a
#===============================================================================
sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;

	my $fragment_size;
	my $random_tries = 0;

	do {
		# seq_size must be greater or equal to fragment_size and
		# fragment_size must be greater or equal to read_size
		# As fragment_size is randomly calculated, try out NUM_TRIES times
		if (++$random_tries == NUM_TRIES) {
			croak "Paired-end read fail: So many tries to calculate a fragment. the constraints were not met:\n" .
			      "fragment_size <= seq_size ($seq_size) and fragment_size >= read_size (" . $self->read_size . ")\n";
		}

		$fragment_size = $self->_random_half_normal;
	} until ($fragment_size <= $seq_size) && ($fragment_size >= $self->read_size);

	my ($fragment_ref, $fragment_pos) = $self->subseq_rand($seq_ref, $seq_size, $fragment_size);	

	my $read1_ref = $self->subseq($fragment_ref, $fragment_size, $self->read_size, 0);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error($read1_ref);

	my $read2_ref = $self->subseq($fragment_ref, $fragment_size, $self->read_size, $fragment_size - $self->read_size);
	$self->reverse_complement($read2_ref);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error($read2_ref);

	return $is_leader ?
		($read1_ref, $read2_ref, $fragment_pos, $fragment_size) :
		($read2_ref, $read1_ref, $fragment_pos, $fragment_size);
} ## --- end sub gen_read

#===  CLASS METHOD  ============================================================
#        CLASS: Read::PairedEnd
#       METHOD: _random_half_normal (PRIVATE)
#   PARAMETERS: Void
#      RETURNS: Int > 0
#  DESCRIPTION: Wrapper to random_normal function that returns value inside a
#               half normal distribution
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _random_half_normal {
	my $self = shift;
	return abs(int(random_normal(1, $self->fragment_mean, $self->fragment_stdd)));
} ## --- end sub _random_half_normal
