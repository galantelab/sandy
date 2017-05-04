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
use Carp;
use namespace::autoclean;

extends 'Read';

sub gen_read {
	my ($self, $seq, $seq_size) = @_;
	my $read = $self->subseq_rand($seq, $seq_size, $self->read_size);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read);
	return $read;
}

__PACKAGE__->meta->make_immutable;

1;
