#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: Fastq::SingleEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 04:23:53 PM
#     REVISION: ---
#===============================================================================

package Fastq::SingleEnd;

use My::Base 'class';
use My::Types;
use Read::SingleEnd;

extends 'Fastq';

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS', required => 1);
has '_read'            => (
	is         => 'ro',
	isa        => 'Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

#===  CLASS METHOD  ============================================================
#        CLASS: Fastq::SingleEnd
#       METHOD: _build_read (BUILDER)
#   PARAMETERS: Void
#      RETURNS: Read::SingleEnd obj
#  DESCRIPTION: Build Read::SingleEnd object
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_read {
	my $self = shift;
	Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size
	);
} ## --- end sub _build_read

#===  CLASS METHOD  ============================================================
#        CLASS: Fastq::SingleEnd
#       METHOD: fastq
#   PARAMETERS: $id Str, $seq_name Str, $seq_ref Ref Str, $seq_size Int > 0, $is_leader Bool
#      RETURNS: sprint_fastq Ref Str
#  DESCRIPTION: Consumes sprint_fastq parent template to generate a single-end fastq entry
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub sprint_fastq {
	my ($self, $id, $seq_name, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read_ref, $pos) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my $seq_pos = $is_leader ?
		"$seq_name:" . ($pos + 1) . "-" . ($pos + $self->read_size) :
		"$seq_name:" . ($pos + $self->read_size) . "-" . ($pos + 1);

	my $header = "$id simulation_read length=" . $self->read_size . " position=$seq_pos";

	return $self->fastq_template(\$header, $read_ref);
} ## --- end sub sprint_fastq

## --- end class Fastq::SingleEnd
