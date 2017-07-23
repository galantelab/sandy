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

sub gen_read {
	my ($self, $seq, $seq_size, $is_leader) = @_;
	# seq_size must be greater or equal to read_size
	if ($seq_size < $self->read_size) {
		croak "single-end read fail: The constraints were not met:\n" .
			"seq_size ($seq_size) >= read_size (" . $self->read_size . ")\n";
	}

	my ($read, $read_pos) = $self->subseq_rand($seq, $seq_size, $self->read_size);

	unless ($is_leader) {
		$self->reverse_complement(\$read);
	}

	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read);
	return ($read, $read_pos);
}

__PACKAGE__->meta->make_immutable;

1;
