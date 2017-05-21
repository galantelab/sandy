#
#===============================================================================
#
#         FILE: SimulateGenome.pm
#
#  DESCRIPTION: Simulates single-end and pair-end reads for genome
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/25/2017 04:50:54 PM
#     REVISION: ---
#===============================================================================

package SimulateGenome;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Params::Validate;
use My::Types;
use Math::Random 'random_uniform_integer';
use Carp 'croak';
use Try::Tiny;
use feature 'say';

use namespace::autoclean;

with qw/My::Role::WeightedRaffle My::Role::IO/;

has 'prefix'          => (is => 'ro', isa => 'Str',       required => 1);
has 'output_gzipped'  => (is => 'ro', isa => 'Bool',      required => 1);
has 'genome_file'     => (is => 'ro', isa => 'My:File',   required => 1);
has 'coverage'        => (is => 'ro', isa => 'My:IntGt0', required => 1);
has 'fastq'           => (
	is         => 'ro',
	isa        => 'Fastq::SingleEnd | Fastq::PairedEnd',
	required   => 1,
	handles    => { get_fastq => 'fastq' }
);
has '_genome'         => (
	is         => 'ro',
	isa        => 'HashRef[HashRef]',
	builder    => '_build_genome',
	lazy_build => 1
);
has '_chr_weight'     => (
	is         => 'ro',
	isa        => 'My:Weights',
	builder    => '_build_chr_weight',
	lazy_build => 1
);

sub _build_genome {
	my $self = shift;

	my $fh = $self->my_open_r($self->genome_file);

	# indexed_genome = ID => (seq, len)
	my %indexed_genome;
	my $id;
	while (<$fh>) {
		chomp;
		if (/^>/) {
			$id = $_;
			$id =~ s/^>//;
		} else {
			croak "Error reading genome '" . $self->genome_file . "': Not defined id"
				unless defined $id;
			$indexed_genome{$id}{seq} .= $_;
		}
	}
	
	for (keys %indexed_genome) {
		$indexed_genome{$_}{size} = length $indexed_genome{$_}{seq};
	}

	close $fh;
	return \%indexed_genome;
}

sub _build_chr_weight {
	my $self = shift;
	my %chr_size = map { $_, $self->_genome->{$_}{size} } keys %{ $self->_genome };
	return $self->calculate_weight(\%chr_size);
}

sub run_simulation {
	my $self = shift;
	my $genome = $self->_genome;

	# Calculate the number of reads to be generated
	my $genome_size = 0;
	$genome_size += $genome->{$_}{size} for keys %{ $genome };
	my $number_of_reads = int(($genome_size * $self->coverage) / $self->fastq->read_size);

	my $fh = $self->my_open_w($self->prefix . "_simulation_seq.fastq", $self->output_gzipped);

	# Run simualtion
	for (my $i = 1; $i <= $number_of_reads; $i++) {
		my $chr = $self->weighted_raffle($self->_chr_weight);
		try {
			say $fh $self->get_fastq("SR$i", $chr, \$genome->{$chr}{seq},
				$genome->{$chr}{size}, random_uniform_integer(1, 0, 1));
		} catch {
			die "[GENOME] $_";
		};
	}

	close $fh;
}

__PACKAGE__->meta->make_immutable;

1;
