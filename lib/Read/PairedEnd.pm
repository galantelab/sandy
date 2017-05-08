#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Read::PairedEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/29/2017 11:58:41 PM
#     REVISION: ---
#===============================================================================

package Read::PairedEnd;

use Moose;
use Carp;
use Math::Random qw/random_normal/;
use namespace::autoclean;

extends 'Read';

has 'fragment_mean' => (is => 'rw', isa => 'Int', required => 1);
has 'fragment_stdd' => (is => 'rw', isa => 'Int', required => 1);

sub gen_read {
	my ($self, $seq, $seq_size) = @_;

	my $fragment_size = int(random_normal(1, $self->fragment_mean, $self->fragment_stdd));
	my $fragment = $self->subseq_rand($seq, $seq_size, $fragment_size);	

	#TODO remove this: The function calling gen_read must skip in error
	return unless defined $fragment;

	my $read1 = $self->subseq(\$fragment, $fragment_size, $self->read_size, 0);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read1);

	my $read2 = $self->subseq(\$fragment, $fragment_size, $self->read_size, $fragment_size - $self->read_size);
	$read2 = reverse $read2;
	$read2 =~ tr/atcgATCG/tagcTAGC/;
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read2);

	return ($read1, $read2);
}

__PACKAGE__->meta->make_immutable;

1;
