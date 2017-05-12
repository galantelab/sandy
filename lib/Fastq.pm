#
#===============================================================================
#
#         FILE: Fastq.pm
#
#  DESCRIPTION: Fastq class
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

use Moose;
use Carp;
use Quality;
use namespace::autoclean;

has 'read_size'        => (is => 'ro', isa => 'Int',   required => 1);
has 'quality_file'     => (is => 'ro', isa => 'Str',   required => 1);
has 'quality'          => (
	is         => 'ro',
	isa        => 'Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

sub _build_quality {
	my $self = shift;
	MakeQuality->new(
		quality_matrix => $self->quality_file,
		quality_size   => $self->read_size
	);
}

before 'fastq' => sub {
	my ($self, $header, $seq) = @_;
	croak "seq argument must be a reference to a SCALAR"
		unless ref $seq eq 'SCALAR';
};

sub fastq {
	my ($self, $header, $seq) = @_;
	
	my $quality = $self->gen_quality;

	my $fastq = "\@$header\n";
	$fastq .= "$$seq\n";
	$fastq .= "+$header\n";
	$fastq .= "$quality";

	return $fastq;
}

__PACKAGE__->meta->make_immutable;

1;
