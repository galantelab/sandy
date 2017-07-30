#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: 'Read::SingleEnd' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/29/2017 09:45:25 PM
#     REVISION: ---
#===============================================================================

package Read::SingleEnd;

use Moose;
use MooseX::StrictConstructor;
use Carp 'croak';

use namespace::autoclean;

extends 'Read';

#===  CLASS METHOD  ============================================================
#        CLASS: Read::SingleEnd
#       METHOD: gen_read
#   PARAMETERS: $seq_ref Ref Str, $seq_size Int > 0, $is_leader Bool
#      RETURNS: $read_ref Ref Str, $read_pos Int >= 0
#  DESCRIPTION: Generate single-end read
#       THROWS: If $seq_size less then read_size, throws an error message
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;
	# seq_size must be greater or equal to read_size
	if ($seq_size < $self->read_size) {
		croak "Single-end read fail: The constraints were not met:\n" .
			  "seq_size ($seq_size) >= read_size (" . $self->read_size . ")\n";
	}

	my ($read_ref, $read_pos) = $self->subseq_rand($seq_ref, $seq_size, $self->read_size);

	unless ($is_leader) {
		$self->reverse_complement($read_ref);
	}

	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error($read_ref);
	return ($read_ref, $read_pos);
} ## --- end sub gen_read

__PACKAGE__->meta->make_immutable;

1; ## --- end class Read::SingleEnd
