#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: SimulateTrascriptome::SingleEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/01/2017 10:25:16 PM
#     REVISION: ---
#===============================================================================

package SimulateTranscriptome::SingleEnd;
 
use Moose;
use MakeQuality;
use Read::SingleEnd;
use Carp;
use namespace::autoclean;

extends 'SimulateTranscriptome';

has 'sequencing_error' => (is => 'ro', isa => 'Num', required => 1);
has 'read_size'        => (is => 'ro', isa => 'Int', required => 1);
has 'read'             => (
	is         => 'ro',
	isa        => 'Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub _build_read {
	my $self = shift;
	Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size
	);
}

sub fastq {
	my ($self, $gene) = @_;

	unless (defined $gene) {
		carp "Not defined gene";
		return;
	}

	my $geneseq = $self->geneseq;
	my $geneinfo = $self->geneinfo;
	my $count = $self->read_count;

	unless (defined $geneinfo->{$gene}) {
		carp "$gene not found inside " . $self->geneseq_file;
		return;	
	}

	my $id = $geneinfo->{$gene}->{id};
	my $quality = $self->gen_quality;
	#TODO keep the seq size inside config_geneinfo
	my $len = length $geneseq->{$id};
	my $read = $self->gen_read(\$geneseq->{$id}, $len);
	
	return unless defined $read and defined $quality;

	my $read_size = $self->read_size;
	$count->{$gene} ++;

	my $fastq = "\@${id}_$count->{$gene} Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$read\n";
	$fastq .= "+${id}_$count->{$gene} Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$quality";

	return $fastq;
}

__PACKAGE__->meta->make_immutable;

1;
