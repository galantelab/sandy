#
#===============================================================================
#
#         FILE: Fastq.pm
#
#  DESCRIPTION: 'Fastq' base class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 04:03:56 PM
#     REVISION: ---
#===============================================================================

package Fastq;

use My::Base 'class';
use Quality;

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'quality_profile'   => (is => 'ro', isa => 'My:QualityP', required => 1, coerce => 1);
has 'read_size'         => (is => 'ro', isa => 'My:IntGt0',   required => 1);
has '_quality'          => (
	is         => 'ro',
	isa        => 'Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

#===  CLASS METHOD  ============================================================
#        CLASS: Fast
#       METHOD: _build_quality (BUILDER)
#   PARAMETERS: Void
#      RETURNS: Quality obj
#  DESCRIPTION: Build Quality object
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_quality {
	my $self = shift;
	Quality->new(
		quality_profile => $self->quality_profile,
		read_size       => $self->read_size
	);
} ## --- end sub _build_quality

#===  CLASS METHOD  ============================================================
#        CLASS: Fast
#       METHOD: sprintf_fastq
#   PARAMETERS: $header_ref Ref Str, $seq_ref Ref Str
#      RETURNS: $fastq Ref Str
#  DESCRIPTION: Fastq entry template
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub fastq_template {
	my ($self, $header_ref, $seq_ref) = @_;
	my $quality_ref = $self->gen_quality;

	my $fastq = "\@$$header_ref\n";
	$fastq .= "$$seq_ref\n";
	$fastq .= "+\n";
	$fastq .= "$$quality_ref";

	return \$fastq;
} ## --- end sub fastq_template

## --- end class Fastq
