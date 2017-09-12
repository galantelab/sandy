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

package App::SimulateReads::Fastq::PairedEnd;
# ABSTRACT: App::SimulateReads::Fastq subclass for simulate paired-end fastq entries.

use App::SimulateReads::Base 'class';
use App::SimulateReads::Read::PairedEnd;

extends 'App::SimulateReads::Fastq';

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'fragment_mean'    => (is => 'rw', isa => 'My:IntGt0', required => 1);
has 'fragment_stdd'    => (is => 'rw', isa => 'My:IntGe0', required => 1);
has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS',  required => 1);
has '_read'            => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Read::PairedEnd',
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
	App::SimulateReads::Read::PairedEnd->new(
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
sub sprint_fastq {
	my ($self, $id, $seq_name, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read1_ref, $read2_ref, $fragment_pos, $fragment_size) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my ($seq_pos1, $seq_pos2) = (
		"$seq_name:" . ($fragment_pos + 1) . "-" . ($fragment_pos + $self->read_size),
		"$seq_name:" . ($fragment_pos + $fragment_size) . "-" . ($fragment_pos + $fragment_size - $self->read_size + 1)
	);

	unless ($is_leader) {
		($seq_pos1, $seq_pos2) = ($seq_pos2, $seq_pos1);
	}

	my $header1 = "$id simulation_read length=" . $self->read_size . " position=$seq_pos1";
	my $header2 = "$id simulation_read length=" . $self->read_size . " position=$seq_pos2";

	my $fastq1_ref = $self->fastq_template(\$header1, $read1_ref);
	my $fastq2_ref = $self->fastq_template(\$header2, $read2_ref);

	return ($fastq1_ref, $fastq2_ref);
} ## --- end sub sprint_fastq
