#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: SimulateTrascriptome::PairedEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/02/2017 05:44:36 PM
#     REVISION: ---
#===============================================================================
 
package SimulateTranscriptome::PairedEnd;
 
use Moose;
use MakeQuality;
use Read::PairedEnd;
use Carp;
use namespace::autoclean;

extends 'SimulateTranscriptome';

has 'sequencing_error' => (is => 'ro', isa => 'Num', required => 1);
has 'read_size'        => (is => 'ro', isa => 'Int', required => 1);
has 'fragment_mean'    => (is => 'rw', isa => 'Int', required => 1);
has 'fragment_stdd'    => (is => 'rw', isa => 'Int', required => 1);
has 'read'             => (
	is         => 'ro',
	isa        => 'Read::PairedEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub _build_read {
	my $self = shift;
	Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
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
	my $quality1 = $self->gen_quality;
	my $quality2 = $self->gen_quality;
	my $len = length $geneseq->{$id};
	my ($read1, $read2) = $self->gen_read(\$geneseq->{$id}, $len);
	
	return unless defined $read1 and defined $read2 and defined $quality1 and defined $quality2;

	my $read_size = $self->read_size;
	$count->{$gene} ++;

	my $fastq = "\@${id}_$count->{$gene} 1 Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$read1\n";
	$fastq .= "+${id}_$count->{$gene} 1 Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$quality1\n";

	$fastq .= "\@${id}_$count->{$gene} 2 Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$read2\n";
	$fastq .= "+${id}_$count->{$gene} 2 Simulation_data gene_name=$gene read_length=$read_size\n";
	$fastq .= "$quality2";

	return $fastq;
}

__PACKAGE__->meta->make_immutable;

1;
