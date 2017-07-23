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
use My::Types;
use Fastq::SingleEnd;
use Fastq::PairedEnd;
use Carp;
use File::Cat 'cat';
use Parallel::ForkManager;

use namespace::autoclean;

with qw/My::Role::WeightedRaffle My::Role::IO/;

has 'threads'         => (is => 'ro', isa => 'My:IntGt0', required => 1);
has 'prefix'          => (is => 'ro', isa => 'Str',       required => 1);
has 'output_gzipped'  => (is => 'ro', isa => 'Bool',      required => 1);
has 'genome_file'     => (is => 'ro', isa => 'My:File',   required => 1);
has 'coverage'        => (is => 'ro', isa => 'My:NumGt0', required => 1);
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

sub _build_genome {
	my $self = shift;

	my $fh = $self->my_open_r($self->genome_file);

	# indexed_genome = ID => (seq, len)
	my %indexed_genome;
	my $id;
	while (<$fh>) {
		chomp;
		next if /^;/;
		if (/^>/) {
			my @fields = split /\|/;
			$id = (split / / => $fields[0])[0];
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

	$fh->close;
	return \%indexed_genome;
}

sub _build_weights {
	my $self = shift;
	my %chr_size = map { $_, $self->_genome->{$_}{size} } keys %{ $self->_genome };
	return $self->calculate_weights(\%chr_size);
}

sub run_simulation {
	my $self = shift;
	my $genome = $self->_genome;

	## Calculate the number of reads to be generated
	my $genome_size = 0;
	$genome_size += $genome->{$_}{size} for keys %{ $genome };
	# In case it is paired-end read, divide the numver of reads by 2 because Fastq::PairedEnd class
	# returns 2 reads at time
	my $read_type_factor = ref $self->fastq eq 'Fastq::PairedEnd' ? 2 : 1;
	my $number_of_reads = int(($genome_size * $self->coverage) / ($self->fastq->read_size * $read_type_factor));

	my $file = $self->prefix . "_simulation_seq.fastq";

	# Forks
	my $number_of_threads = $self->threads;
	my @tmp_files;
	my $pm = Parallel::ForkManager->new($number_of_threads);

	for my $tid (1..$number_of_threads) {
		# Inside parent
		my $file_t = "$file.${$}_$tid";
		push @tmp_files => $file_t;
		my $pid = $pm->start and next;	

		# Inside child
		my $seed = time + $$;
		srand($seed);

		my $number_of_reads_t = int($number_of_reads/$number_of_threads);
		# If it is the first thread, make it work on the leftover reads of int() truncation
		$number_of_reads_t += $number_of_reads % $number_of_threads
			if $tid == 1;

		my $fh = $self->my_open_w($file_t, 0);

		# Run simualtion in child
		for my $i (1..$number_of_reads_t) {
			my $chr = $self->weighted_raffle;
			$fh->say(
				$self->get_fastq("SR${i}.$tid", $chr, \$genome->{$chr}{seq},
					$genome->{$chr}{size}, int(rand(2)))
			);
		}

		$fh->close;
		$pm->finish;
	}

	# Back to parent
	$pm->wait_all_children;

	# Concatenate all temporary files
	my $fh = $self->my_open_w($file, $self->output_gzipped);
	for my $file_t (@tmp_files) {
		cat $file_t => $fh
			or carp "Cannot concatenate $file_t to $file: $!";
	}

	$fh->close;

	# Clean up the mess
	for my $file_t (@tmp_files) {
		unlink $file_t
			or carp "Cannot remove temporary file: $file_t: $!";
	}
}

__PACKAGE__->meta->make_immutable;

1;
