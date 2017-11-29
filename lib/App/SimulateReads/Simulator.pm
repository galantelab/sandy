package App::SimulateReads::Simulator;
# ABSTRACT: Class responsible to make the simulation

use App::SimulateReads::Base 'class';
use App::SimulateReads::Fastq::SingleEnd;
use App::SimulateReads::Fastq::PairedEnd;
use App::SimulateReads::InterlaceProcesses;
use Scalar::Util 'looks_like_number';
use File::Cat 'cat';
use Parallel::ForkManager;

with qw/App::SimulateReads::Role::WeightedRaffle App::SimulateReads::Role::IO/;

# VERSION

has 'jobs' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 1
);

has 'prefix' => (
	is         => 'ro',
	isa        => 'Str',
	required   => 1
);

has 'output_gzip' => (
	is         => 'ro',
	isa        => 'Bool',
	required   => 1
);

has 'fasta_file' => (
	is         => 'ro',
	isa        => 'My:Fasta',
	required   => 1
);

has 'coverage' => (
	is         => 'ro',
	isa        => 'My:NumGt0',
	required   => 0
);

has 'number_of_reads' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 0
);

has 'count_loops_by' => (
	is         => 'ro',
	isa        => 'My:CountLoopBy',
	required   => 1
);

has 'strand_bias' => (
	is         => 'ro',
	isa        => 'My:StrandBias',
	required   => 1
);

has 'seqid_weight' => (
	is         => 'ro',
	isa        => 'My:SeqIdWeight',
	required   => 1
);

has 'weight_file' => (
	is         => 'ro',
	isa        => 'My:File',
	required   => 0
);

has 'fastq' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Fastq::SingleEnd | App::SimulateReads::Fastq::PairedEnd',
	required   => 1,
	handles    => [ qw{ sprint_fastq } ]
);

has '_fasta' => (
	is         => 'ro',
	isa        => 'My:IdxFasta',
	builder    => '_build_fasta',
	lazy_build => 1
);

has '_strand' => (
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_strand',
	lazy_build => 1
);

has '_seqid_raffle' => (
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_seqid_raffle',
	lazy_build => 1
);

sub BUILD {
	my $self = shift;

	# If seqid_weight is 'file', then weight_file must be defined
	if ($self->seqid_weight eq 'file' and not defined $self->weight_file) {
		croak "seqid_weight=file requires a weight_file\n";
	}

	# If count_loops_by is 'coverage', then coverage must be defined. Else if
	# it is equal to 'number_of_reads', then number_of_reads must be defined
	if ($self->count_loops_by eq 'coverage' and not defined $self->coverage) {
		croak "count_loops_by=coverage requires a coverage number\n";
	} elsif ($self->count_loops_by eq 'number_of_reads' and not defined $self->number_of_reads) {
		croak "count_loops_by=number_of_reads requires a number_of_reads number\n";
	}
	
	## Just to ensure that the lazy attributes are built before &new returns
	# Only seqid_weight=same is not a weighted raffle, so in this case
	# not construct weight attribute
	$self->weights if $self->seqid_weight ne 'same';
	$self->_strand;
	$self->_fasta;
	$self->_seqid_raffle;
}
 
sub _build_strand {
	my $self = shift;
	my $strand_sub;

	given ($self->strand_bias) {
		when ('plus')   { $strand_sub = sub {1} }
		when ('minus')  { $strand_sub = sub {0} }
		when ('random') { $strand_sub = sub { int(rand(2)) }}
		default         { croak "Unknown option '$_' for strand bias\n" }
	}

	return $strand_sub;
}

sub _index_fasta {
	my $self = shift;
	my $fasta = $self->fasta_file;

	my $fh = $self->my_open_r($fasta);

	# indexed_genome = ID => (seq, len)
	my %indexed_fasta;
	my $id;
	while (<$fh>) {
		chomp;
		next if /^;/;
		if (/^>/) {
			my @fields = split /\|/;
			$id = (split / / => $fields[0])[0];
			$id =~ s/^>//;
			$id = uc $id;
		} else {
			croak "Error reading fasta file '$fasta': Not defined id"
				unless defined $id;
			$indexed_fasta{$id}{seq} .= $_;
		}
	}
	
	for (keys %indexed_fasta) {
		$indexed_fasta{$_}{size} = length $indexed_fasta{$_}{seq};
	}

	unless (%indexed_fasta) {
		croak "Error parsing '$fasta'. Maybe the file is empty\n";
	}

	$fh->close
		or croak "Cannot close file $fasta: $!\n";

	return \%indexed_fasta;
}

sub _build_fasta {
	my $self = shift;
	log_msg ":: Indexing fasta file '" . $self->fasta_file . "' ...";
	my $indexed_fasta = $self->_index_fasta($self->fasta_file);

	# Validate genome about the read size required
	for my $id (keys %$indexed_fasta) {
		my $index_size = $indexed_fasta->{$id}{size};
		given (ref $self->fastq) {
			when ('App::SimulateReads::Fastq::SingleEnd') {
				my $read_size = $self->fastq->read_size;
				if ($index_size < $read_size) {
					log_msg ":: seqid sequence length (>$id => $index_size) lesser than required read size ($read_size)\n" .
						"  -> I'm going to include '>$id' in the blacklist\n";
					delete $indexed_fasta->{$id};
				}
			}
			when ('App::SimulateReads::Fastq::PairedEnd') {
				my $fragment_mean = $self->fastq->fragment_mean;
				if ($index_size < $fragment_mean) {
					log_msg ":: seqid sequence length (>$id => $index_size) lesser than required fragment mean ($fragment_mean)\n" .
						"  -> I'm going to include '>$id' in the blacklist\n";
					delete $indexed_fasta->{$id};
				}
			}
			default {
				croak "Unknown option '$_' for sequencing type\n";
			}
		}
	}
	
	unless (%$indexed_fasta) {
		croak sprintf "Fasta file '%s' has no valid entry\n" => $self->fasta_file;
	}

	return $indexed_fasta;
}

sub _index_weight_file {
	my $self = shift;
	my $weight_file = $self->weight_file;

	my $fh = $self->my_open_r($weight_file);
	my %indexed_file;

	my $line = 0;
	while (<$fh>) {
		$line++;
		chomp;
		next if /^\s*$/;

		my @fields = split /\t/;

		croak "Error parsing '$weight_file': seqid (first column) not found at line $line\n"
			unless defined $fields[0];
		croak "Error parsing '$weight_file': weight (second column) not found at line $line\n"
			unless defined $fields[1];
		croak "Error parsing '$weight_file': weight (second column) does not look like a number at line $line\n"
			if not looks_like_number($fields[1]);
		croak "Error parsing '$weight_file': weight (second column) lesser or equal to zero at line $line\n"
			if $fields[1] <= 0;

		$indexed_file{uc $fields[0]} = $fields[1];
	}
	
	unless (%indexed_file) {
		croak "Error parsing '$weight_file': Maybe the file is empty\n"
	}

	$fh->close
		or croak "Cannot close file $weight_file: $!\n";

	return \%indexed_file;
}

sub _build_weights {
	my $self = shift;
	my $weights;

	given ($self->seqid_weight) {
		when ('length') {
			my %chr_size = map { $_, $self->_fasta->{$_}{size} } keys %{ $self->_fasta };
			$weights = $self->calculate_weights(\%chr_size);
		}
		when ('file') {
			log_msg ":: Indexing weight file '" . $self->weight_file . "' ...";
			my $indexed_file = $self->_index_weight_file($self->weight_file);

			# Validate weight_file
			my $indexed_fasta = $self->_fasta;

			for my $id (keys %$indexed_file) {
				if (not exists $indexed_fasta->{$id}) {
					log_msg "Ignoring seqid '$id': It is not found at the indexed fasta";
					delete $indexed_file->{$id};
				}
			}

			unless (%$indexed_file) {
				croak "No seqid entry of the file '" . $self->weight_file . "' is recorded in the indexed fasta\n";
			}

			$weights = $self->calculate_weights($indexed_file);
		}
		when ('same') {
			croak "Error: Cannot build raffle weights for 'seqid-weight=same'\n";
		}
		default {
			croak "Unknown option '$_' for weighted raffle\n";
		}
	}

	return $weights;
}

sub _build_seqid_raffle {
	my $self = shift;
	my $seqid_sub;
	given ($self->seqid_weight) {
		when ('same') {
			my @seqids = keys %{ $self->_fasta };
			my $seqids_size = scalar @seqids;
			$seqid_sub = sub { $seqids[int(rand($seqids_size))] };
		}
		when (/^(file|length)$/) {
			$seqid_sub = sub { $self->weighted_raffle };
		}
		default {
			croak "Unknown option '$_' for seqid-raffle\n";
		}
	}
	return $seqid_sub;
}

sub _calculate_number_of_reads {
	my $self = shift;
	my $number_of_reads;
	given($self->count_loops_by) {
		when ('coverage') {
			# It is needed to calculate the genome size
			my $fasta = $self->_fasta;
			my $fasta_size = 0;
			$fasta_size += $fasta->{$_}{size} for keys %{ $fasta };
			$number_of_reads = int(($fasta_size * $self->coverage) / $self->fastq->read_size);
		}
		when ('number-of-reads') {
			$number_of_reads = $self->number_of_reads;
		}
		default {
			croak "Unknown option '$_' for calculating the number of reads\n";
		}
	}

	# In case it is paired-end read, divide the number of reads by 2 because App::SimulateReads::Fastq::PairedEnd class
	# returns 2 reads at time
	my $class = ref $self->fastq;
	my $read_type_factor = $class eq 'App::SimulateReads::Fastq::PairedEnd' ? 2 : 1;
	$number_of_reads = int($number_of_reads / $read_type_factor);

	# Maybe the number_of_reads is zero. It may occur due to the low coverage and/or fasta_file size
	if ($number_of_reads <= 0 || ($class eq 'App::SimulateReads::Fastq::PairedEnd' && $number_of_reads == 1)) {
		croak "The computed number of reads is equal to zero.\n" . 
		      "It may occur due to the low coverage, fasta-file sequence size or number of reads directly passed by the user\n";
	}

	return $number_of_reads;
}

sub run_simulation {
	my $self = shift;
	my $fasta = $self->_fasta;

	# Calculate the number of reads to be generated
	my $number_of_reads = $self->_calculate_number_of_reads;

	# Function that returns strand by strand_bias
	my $strand = $self->_strand;

	# Function that returns seqid by seqid_weight
	my $seqid = $self->_seqid_raffle;

	# Files to be generated
	my %files = (
		'App::SimulateReads::Fastq::SingleEnd' => [
			$self->prefix . '_simulation_read.fastq'
		],
		'App::SimulateReads::Fastq::PairedEnd' => [
			$self->prefix . '_simulation_read_R1.fastq',
			$self->prefix . '_simulation_read_R2.fastq'
		],
	);

	# Is it single-end or paired-end?
	my $fastq_class = ref $self->fastq;

	# Forks
	my $number_of_jobs = $self->jobs;
	my $pm = Parallel::ForkManager->new($number_of_jobs);
	
	# Parent child pids
	my $parent_pid = $$;
	my @child_pid;

	# Temporary files tracker
	my @tmp_files;

	# Run in parent right after creating child process
	$pm->run_on_start(
		sub {
			my ($pid, $files_ref) = @_;
			push @child_pid => $pid;
			push @tmp_files => @$files_ref;
		}
	);

	log_msg sprintf ":: Creating %d child %s ...",
		$number_of_jobs, $number_of_jobs == 1 ? "job" : "jobs";

	for my $tid (1..$number_of_jobs) {
		#-------------------------------------------------------------------------------
		# Inside parent
		#-------------------------------------------------------------------------------
		log_msg ":: Creating job $tid ...";
		my @files_t = map { "$_.${parent_pid}_part$tid" } @{ $files{$fastq_class} };
		my $pid = $pm->start(\@files_t) and next;	

		#-------------------------------------------------------------------------------
		# Inside child 
		#-------------------------------------------------------------------------------
		# Intelace child/parent processes
		my $sig = App::SimulateReads::InterlaceProcesses->new(foreign_pid => [$parent_pid]);

		# Set child seed
		my $seed = time + $$;
		srand($seed);

		# Calculate the number of reads to this job and correct this local index
		# to the global index
		my $number_of_reads_t = int($number_of_reads/$number_of_jobs);
		my $last_read_idx = $number_of_reads_t * $tid;
		my $idx = $last_read_idx - $number_of_reads_t + 1;

		# If it is the last job, make it work on the leftover reads of int() truncation
		$last_read_idx += $number_of_reads % $number_of_jobs
			if $tid == $number_of_jobs;

		log_msg "  => Job $tid: Working on reads from $idx to $last_read_idx";

		# Create temporary files
		log_msg "  => Job $tid: Creating temporary file: @files_t";
		my @fhs = map { $self->my_open_w($_, $self->output_gzip) } @files_t;

		# Run simualtion in child
		for (my $i = $idx; $i <= $last_read_idx and not $sig->signal_catched; $i++) {
			my $id = $seqid->();
			my @fastq_entry;
			try {
				@fastq_entry = $self->sprint_fastq("SR${parent_pid}.$id.$i $i",
					$id, \$fasta->{$id}{seq}, $fasta->{$id}{size}, $strand->());
			} catch {
				croak "Not defined entry for seqid '>$id' at job $tid: $_";
			} finally {
				unless (@_) {
					for my $fh_idx (0..$#fhs) {
						$fhs[$fh_idx]->say(${$fastq_entry[$fh_idx]})
							or croak "Cannot write to $files_t[$fh_idx]: $!\n";
					}
				}
			};
		}

		log_msg "  => Job $tid: Writing and closing file: @files_t";
		# Close temporary files
		for my $fh_idx (0..$#fhs) {
			$fhs[$fh_idx]->close
				or croak "Cannot write file $files_t[$fh_idx]: $!\n";
		}

		# Child exit
		log_msg "  => Job $tid is finished";
		$pm->finish;
	}

	# Back to parent
	# Interlace parent/child(s) processes
	my $sig = App::SimulateReads::InterlaceProcesses->new(foreign_pid => \@child_pid);
	$pm->wait_all_children;

	if ($sig->signal_catched) {
		log_msg ":: Termination signal received!";
	}

	log_msg ":: Saving the work ...";

	# Concatenate all temporary files
	log_msg ":: Concatenating all temporary files ...";
	my @fh = map { $self->my_open_w($self->output_gzip ? "$_.gz" : $_, 0) } @{ $files{$fastq_class} };
	for my $i (0..$#tmp_files) {
		my $fh_idx = $i % scalar @fh;
		cat $tmp_files[$i] => $fh[$fh_idx]
			or croak "Cannot concatenate $tmp_files[$i] to $files{$fastq_class}[$fh_idx]: $!\n";
	}

	# Close files
	log_msg ":: Writing and closing output file: @{ $files{$fastq_class} }";
	for my $fh_idx (0..$#fh) {
		$fh[$fh_idx]->close
			or croak "Cannot write file $files{$fastq_class}[$fh_idx]: $!\n";
	}

	# Clean up the mess
	log_msg ":: Removing temporary files ...";
	for my $file_t (@tmp_files) {
		unlink $file_t
			or croak "Cannot remove temporary file: $file_t: $!\n";
	}
}
