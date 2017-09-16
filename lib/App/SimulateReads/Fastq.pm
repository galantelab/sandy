package App::SimulateReads::Fastq;
# ABSTRACT: Base class to simulate fastq entries

use App::SimulateReads::Base 'class';
use App::SimulateReads::Quality;

# VERSION

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'quality_profile'   => (is => 'ro', isa => 'My:QualityP', required => 1, coerce => 1);
has 'read_size'         => (is => 'ro', isa => 'My:IntGt0',   required => 1);
has '_quality'          => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_quality;
}

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
	App::SimulateReads::Quality->new(
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
