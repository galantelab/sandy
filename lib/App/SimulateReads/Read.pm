package App::SimulateReads::Read;
# ABSTRACT: Base class to simulate reads

use App::SimulateReads::Base 'class';

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS',  required => 1);
has 'read_size'        => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_count_base'      => (is => 'rw', isa => 'Int',       default  => 0);
has '_base'            => (is => 'rw', isa => 'Int');

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: BUILD (Moose)
#   PARAMETERS: Void
#      RETURNS: Void
#  DESCRIPTION: Set the _base attribute. If sequencing_error is zero, set it to
#               zero too
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub BUILD {
	my $self = shift;
	# If sequencing_error equal to zero, set _base to zero
	$self->_base($self->sequencing_error ? int(1 / $self->sequencing_error) : 0);
} ## --- end sub BUILD

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: subseq
#   PARAMETERS: $seq_ref Ref Str, $seq_len Int > 0, $slice_len Int > 0, $pos Int >= 0
#      RETURNS: $read Ref Str
#  DESCRIPTION: Wrapper to substr built in function
#       THROWS: no exceptions
#     COMMENTS: $slice_len, also plus $pos, must be lesser or equal to $seq_len
#     SEE ALSO: n/a
#===============================================================================
sub subseq {
	my ($self, $seq_ref, $seq_len, $slice_len, $pos) = @_;
	my $read = substr $$seq_ref, $pos, $slice_len;
	return \$read;
} ## --- end sub subseq

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: subseq_rand
#   PARAMETERS: $seq_ref Ref Str, $seq_len Int > 0, $slice_len Int > 0
#      RETURNS: $read Ref Str, $pos Int >= 0
#  DESCRIPTION: Wrapper to substr built in function that slices into a random position
#       THROWS: no exceptions
#     COMMENTS: $slice_len must must be lesser or equal than $seq_len
#     SEE ALSO: n/a
#===============================================================================
sub subseq_rand {
	my ($self, $seq_ref, $seq_len, $slice_len) = @_;
	my $usable_len = $seq_len - $slice_len;
	my $pos = int(rand($usable_len + 1));
	my $read = substr $$seq_ref, $pos, $slice_len;
	return (\$read, $pos);
} ## --- end sub subseq_rand

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: insert_sequencing_error
#   PARAMETERS: $seq_ref Ref Str
#      RETURNS: Void
#  DESCRIPTION: Insert sequencing error in place
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub insert_sequencing_error {
	my ($self, $seq_ref) = @_;
	my $err = int($self->_count_base * $self->sequencing_error);

	for (my $i = 0; $i < $err; $i++) {
		$self->update_count_base(-$self->_base);
		my $pos = $self->read_size - $self->_count_base - 1;
		my $b = substr($$seq_ref, $pos, 1);
		substr($$seq_ref, $pos, 1) = $self->_randb($b);
	}
} ## --- end sub insert_sequencing_error

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: update_count_base
#   PARAMETERS: $val Int
#      RETURNS: Void
#  DESCRIPTION: Increment or decrement _count_base which controls when insert an
#               error and how many: int($self->_count_base * $self->sequencing_error);
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub update_count_base {
	my ($self, $val) = @_;
	$self->_count_base($self->_count_base + $val);
} ## --- end sub update_count_base

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: reverse_complement
#   PARAMETERS: $seq_ref Ref Str
#      RETURNS: Void
#  DESCRIPTION: Compute the reverse complement sequence in place
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub reverse_complement {
	my ($self, $seq_ref) = @_;
	$$seq_ref = reverse $$seq_ref;
	$$seq_ref =~ tr/atcgATCG/tagcTAGC/;
} ## --- end sub reverse_complement

#===  CLASS METHOD  ============================================================
#        CLASS: Read
#       METHOD: _randb (PRIVATE)
#   PARAMETERS: $not_b Char
#      RETURNS: $b Char
#  DESCRIPTION: Raffle a ramdom base, but $not_b
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _randb {
	my ($self, $not_b) = ($_[0], uc $_[1]);
	my $b;
	do { $b = qw{A T C G}[int(rand(4))] } until ($b ne $not_b);
	return $b;
} ## --- end sub _randb
