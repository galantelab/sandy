package App::SimulateReads::Fastq;
# ABSTRACT: Base class to simulate fastq entries

use App::SimulateReads::Base 'class';
use App::SimulateReads::Quality;

our $VERSION = '0.04'; # VERSION

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

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Fastq - Base class to simulate fastq entries

=head1 VERSION

version 0.04

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
