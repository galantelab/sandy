#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Fastq::PairedEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 05:06:32 PM
#     REVISION: ---
#===============================================================================

package Fastq::PairedEnd;

use Moose;
use MooseX::StrictConstructor;
use My::Types;
use Read::PairedEnd;

use namespace::autoclean;

extends 'Fastq';

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'fragment_mean'    => (is => 'rw', isa => 'My:IntGt0', required => 1);
has 'fragment_stdd'    => (is => 'rw', isa => 'My:IntGe0', required => 1);
has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS',  required => 1);
has '_read'            => (
	is         => 'ro',
	isa        => 'Read::PairedEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

#===  CLASS METHOD  ============================================================
#        CLASS: Fastq::PairedEnd
#       METHOD: _build_read (BUILDER)
#   PARAMETERS: Void
#      RETURNS: Read::PairedEnd obj
#  DESCRIPTION: Build a Read::PairedEnd object
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_read {
	my $self = shift;
	Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);
} ## --- end sub _build_read

#===  CLASS METHOD  ============================================================
#        CLASS: Fastq::PairedEnd
#       METHOD: fastq
#   PARAMETERS: $id Str, $seq_name Str, $seq_ref Ref Str, $seq_size Int > 0,
#               $is_leader Bool
#      RETURNS: $fastq Ref Str
#  DESCRIPTION: Consumes sprint_fastq parent template, twice, to generate a 
#               paired-end fastq entry
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub fastq {
	my ($self, $id, $seq_name, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read1_ref, $read2_ref, $fragment_pos, $fragment_size) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my ($seq_pos1, $seq_pos2) = (
		"$seq_name:" . ($fragment_pos + 1) . "-" . ($fragment_pos + $self->read_size),
		"$seq_name:" . ($fragment_pos + $fragment_size) . "-" . ($fragment_pos + $fragment_size - $self->read_size + 1)
	);

	unless ($is_leader) {
		($seq_pos1, $seq_pos2) = ($seq_pos2, $seq_pos1);
	}

	my $header1 = "$id|$seq_pos1 1 simulation_read length=" . $self->read_size;
	my $header2 = "$id|$seq_pos2 2 simulation_read length=" . $self->read_size;

	my $fastq1_ref = $self->sprint_fastq(\$header1, $read1_ref);
	my $fastq2_ref = $self->sprint_fastq(\$header2, $read2_ref);

	return ($fastq1_ref, $fastq2_ref);
} ## --- end sub fastq

__PACKAGE__->meta->make_immutable;

1; ## --- end class Fastq::PairedEnd
