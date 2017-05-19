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
use Carp; 
use Try::Tiny;
use feature 'say';
use namespace::autoclean;

with 'Role::WeightedRaffle';

has 'genome_file' => (is => 'ro', isa => 'Str', required => 1);
has 'coverage'    => (is => 'ro', isa => 'Int', required => 1);
has 'fastq'       => (
	is         => 'ro',
	isa        => 'Fastq::SingleEnd | Fastq::PairedEnd',
	required   => 1,
	handles    => { get_fastq => 'fastq' }
);
has '_genome'     => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_genome'
);
has '_chr_weight' => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_chr_weight',
	lazy_build => 1
);

# TODO: Pass this function to Roles
sub _build_genome {
	my $self = shift;

	my $fh;
	if ($self->genome =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->genome
			or croak "Not possible to open pipe to " . $self->genome . ": $!";
	} else {
		open $fh, "<" => $self->genome
			or croak "Not possible to read " . $self->genome . ": $!";
	}

	# indexed_genome = ID => (seq, len)
	my %indexed_genome;
	my $id;
	while (<$fh>) {
		chomp;
		if (/^>/) {
			$id = $_;
			$id =~ s/^>//;
		} else {
			croak "Error reading genome '" . $self->genome . "': Not defined id"
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
	return $self->_calculate_weight(\%chr_size);
}

sub run_simulation {
	my $self = shift;
	my $genome = $self->_genome;

	# Calculate the number of reads to be generated
	my $genome_size = 0;
	$genome_size += $genome->{$_}{size} for keys %{ $genome };
	my $number_of_reads = int(($genome_size * $self->coverage) / $self->fastq->read_size);

	# Run simualtion
	for (my $i = 1; $i <= $number_of_reads; $i++) {
		my $chr = $self->_raffle_chr;			
		try {
			say $self->get_fastq("SR$i", $chr, $genome->{$chr}{seq}, $genome->{$chr}{size}, int(rand(2)));
		} catch {
			die "[GENOME] $_";
		};
	}
}

sub _raffle_chr {
	my $self = shift;
	my $chr_weight = $self->_chr_weight;
	my $range = int(rand($chr_weight->{acm} + 1));
	my $weights = $chr_weight->{weights};
	return $self->_search($weights, 0, $#{$weights}, $range);
}

__PACKAGE__->meta->make_immutable;

1;
