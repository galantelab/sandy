package App::SimulateReads::Simulator;
# ABSTRACT: Class responsible to make the simulation

use App::SimulateReads::Base 'class';
use App::SimulateReads::Fastq::SingleEnd;
use App::SimulateReads::Fastq::PairedEnd;
use App::SimulateReads::InterlaceProcesses;
use App::SimulateReads::WeightedRaffle;
use App::SimulateReads::DB::Handle::Expression;
use Scalar::Util 'looks_like_number';
use File::Cat 'cat';
use Parallel::ForkManager;

with qw/App::SimulateReads::Role::IO/;

# VERSION

has 'seed' => (
	is        => 'ro',
	isa       => 'Int',
	required  => 1
);

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

has 'expression_matrix' => (
	is         => 'ro',
	isa        => 'Str',
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

has '_fasta_tree' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[ArrayRef]',
	default    => sub { {} },
	handles    => {
		_set_fasta_tree    => 'set',
		_get_fasta_tree    => 'get',
		_exists_fasta_tree => 'exists',
		_fasta_tree_pairs  => 'kv',
		_has_no_fasta_tree => 'is_empty'
	}
);

has '_fasta_rtree' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[Str]',
	default    => sub { {} },
	handles    => {
		_set_fasta_rtree    => 'set',
		_get_fasta_rtree    => 'get',
		_delete_fasta_rtree => 'delete',
		_exists_fasta_rtree => 'exists',
		_fasta_rtree_pairs  => 'kv',
		_has_no_fasta_rtree => 'is_empty'
	}
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

	# If seqid_weight is 'count', then expression_matrix must be defined
	if ($self->seqid_weight eq 'count' and not defined $self->expression_matrix) {
		die "seqid_weight=count requires a expression_matrix\n";
	}

	# If count_loops_by is 'coverage', then coverage must be defined. Else if
	# it is equal to 'number_of_reads', then number_of_reads must be defined
	if ($self->count_loops_by eq 'coverage' and not defined $self->coverage) {
		die "count_loops_by=coverage requires a coverage number\n";
	} elsif ($self->count_loops_by eq 'number_of_reads' and not defined $self->number_of_reads) {
		die "count_loops_by=number_of_reads requires a number_of_reads number\n";
	}

	## Just to ensure that the lazy attributes are built before &new returns
	$self->_seqid_raffle;
	$self->_fasta;
	$self->_strand;
}

sub _build_strand {
	my $self = shift;
	my $strand_sub;

	given ($self->strand_bias) {
		when ('plus')   { $strand_sub = sub {1} }
		when ('minus')  { $strand_sub = sub {0} }
		when ('random') { $strand_sub = sub { int(rand(2)) }}
		default         { die "Unknown option '$_' for strand bias\n" }
	}

	return $strand_sub;
}

sub _index_fasta {
	my $self = shift;
	my $fasta = $self->fasta_file;

	my $fh = $self->my_open_r($fasta);

	# indexed_genome = ID => (seq, len)
	my %indexed_fasta;

	# >ID|PID as in gencode transcripts
	my %fasta_rtree;
	my $id;

	while (<$fh>) {
		chomp;
		next if /^;/;
		if (/^>/) {
			my @fields = split /\|/;
			$id = $fields[0];
			$id =~ s/^>//;
			$id =~ s/^\s+|\s+$//g;

			# It is necessary to catch gene -> transcript relation
			# # TODO: Make a hash tarit for indexed fasta
			if (defined $fields[1]) {
				my $pid = $fields[1];
				$pid =~ s/^\s+|\s+$//g;
				$fasta_rtree{$id} = $pid;
			}
		} else {
			die "Error reading fasta file '$fasta': Not defined id"
				unless defined $id;
			$indexed_fasta{$id}{seq} .= $_;
		}
	}

	for (keys %indexed_fasta) {
		$indexed_fasta{$_}{size} = length $indexed_fasta{$_}{seq};
	}

	unless (%indexed_fasta) {
		die "Error parsing '$fasta'. Maybe the file is empty\n";
	}

	$fh->close
		or die "Cannot close file $fasta: $!\n";

	$self->_set_fasta_rtree(%fasta_rtree) if %fasta_rtree;
	return \%indexed_fasta;
}

sub _build_fasta {
	my $self = shift;
	my $fasta = $self->fasta_file;

	log_msg ":: Indexing fasta file '$fasta' ...";
	my $indexed_fasta = $self->_index_fasta;

	# Validate genome about the read size required
	log_msg ":: Validating fasta file '$fasta' ...";
	# Entries to remove
	my @blacklist;

	for my $id (keys %$indexed_fasta) {
		my $index_size = $indexed_fasta->{$id}{size};
		given (ref $self->fastq) {
			when ('App::SimulateReads::Fastq::SingleEnd') {
				my $read_size = $self->fastq->read_size;
				if ($index_size < $read_size) {
					log_msg ":: Parsing fasta file '$fasta': Seqid sequence length (>$id => $index_size) lesser than required read size ($read_size)\n" .
						"  -> I'm going to include '>$id' in the blacklist\n";
					delete $indexed_fasta->{$id};
					push @blacklist => $id;
				}
			}
			when ('App::SimulateReads::Fastq::PairedEnd') {
				my $fragment_mean = $self->fastq->fragment_mean;
				if ($index_size < $fragment_mean) {
					log_msg ":: Parsing fasta file '$fasta': Seqid sequence length (>$id => $index_size) lesser than required fragment mean ($fragment_mean)\n" .
						"  -> I'm going to include '>$id' in the blacklist\n";
					delete $indexed_fasta->{$id};
					push @blacklist => $id;
				}
			}
			default {
				die "Unknown option '$_' for sequencing type\n";
			}
		}
	}

	unless (%$indexed_fasta) {
		die sprintf "Fasta file '%s' has no valid entry\n" => $self->fasta_file;
	}

	# Remove no valid entries from id -> pid relation
	$self->_delete_fasta_rtree(@blacklist) if @blacklist;

	# Reverse fasta_rtree to pid -> \@ids
	unless ($self->_has_no_fasta_rtree) {
		# Build parent -> child ids relation
		my %fasta_tree;

		for my $pair ($self->_fasta_rtree_pairs) {
			my ($id, $pid) = (@$pair);
			push @{ $fasta_tree{$pid} } => $id;
		}

		# Need to sort ids to ensure that raffle will
		# be reproducible
		while (my ($pid, $ids) = each %fasta_tree) {
			my @sorted_ids = sort @$ids;
			$fasta_tree{$pid} = \@sorted_ids;
		}

		$self->_set_fasta_tree(%fasta_tree);
	}

	return $indexed_fasta;
}

sub _retrieve_expression_matrix {
	my $self = shift;
	my $expression = App::SimulateReads::DB::Handle::Expression->new;
	return $expression->retrievedb($self->expression_matrix);
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
		when ('count') {
			# Catch expression-matrix entry from database
			my $indexed_file = $self->_retrieve_expression_matrix;

			# Validate expression_matrix
			my $indexed_fasta = $self->_fasta;

			for my $id (keys %$indexed_file) {
				# If not exists into indexed_fasta, it must then exist into fasta_tree
				unless (exists $indexed_fasta->{$id} || $self->_exists_fasta_tree($id)) {
					log_msg sprintf ":: Ignoring seqid '$id' from expression-matrix '%s': It is not found into the indexed fasta file '%s'"
						=> $self->expression_matrix, $self->fasta_file;
					delete $indexed_file->{$id};
				}
			}

			unless (%$indexed_file) {
				die sprintf "No valid seqid entry of the expression-matrix '%s' is recorded into the indexed fasta file '%s'\n"
					=> $self->expression_matrix, $self->fasta_file;
			}

			my $raffler = App::SimulateReads::WeightedRaffle->new(
				weights => $indexed_file
			);

			$seqid_sub = sub {
				my $seqid = $raffler->weighted_raffle;
				# The user could have passed the 'gene' instead of 'transcript'
				if ($self->_exists_fasta_tree($seqid)) {
					my $fasta_tree_entry = $self->_get_fasta_tree($seqid);
					$seqid = $fasta_tree_entry->[int(rand(@$fasta_tree_entry))];
				}
				return $seqid;
			};
		}
		when ('length') {
			my %chr_size = map { $_, $self->_fasta->{$_}{size} } keys %{ $self->_fasta };

			my $raffler = App::SimulateReads::WeightedRaffle->new(
				weights => \%chr_size
			);

			$seqid_sub = sub { $raffler->weighted_raffle };
		}
		default {
			die "Unknown option '$_' for seqid-raffle\n";
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
			die "Unknown option '$_' for calculating the number of reads\n";
		}
	}

	# In case it is paired-end read, divide the number of reads by 2 because App::SimulateReads::Fastq::PairedEnd class
	# returns 2 reads at time
	my $class = ref $self->fastq;
	my $read_type_factor = $class eq 'App::SimulateReads::Fastq::PairedEnd' ? 2 : 1;
	$number_of_reads = int($number_of_reads / $read_type_factor);

	# Maybe the number_of_reads is zero. It may occur due to the low coverage and/or fasta_file size
	if ($number_of_reads <= 0 || ($class eq 'App::SimulateReads::Fastq::PairedEnd' && $number_of_reads == 1)) {
		die "The computed number of reads is equal to zero.\n" .
			"It may occur due to the low coverage, fasta-file sequence size or number of reads directly passed by the user\n";
	}

	return $number_of_reads;
}

sub _set_seed {
	my ($self, $inc) = @_;
	my $seed = defined $inc ? $self->seed + $inc : $self->seed;
	srand($seed);
	require Math::Random;
	Math::Random::random_set_seed_from_phrase($seed);
}

sub _calculate_parent_count {
	my ($self, $counter_ref) = @_;
	return if $self->_has_no_fasta_rtree;

	my %parent_count;

	while (my ($id, $count) = each %$counter_ref) {
		my $pid = $self->_get_fasta_rtree($id);
		$parent_count{$pid} += $count if defined $pid;
	}

	return \%parent_count;
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

	# Fastq files to be generated
	my %files = (
		'App::SimulateReads::Fastq::SingleEnd' => [
			$self->prefix . '_R1_001.fastq'
		],
		'App::SimulateReads::Fastq::PairedEnd' => [
			$self->prefix . '_R1_001.fastq',
			$self->prefix . '_R2_001.fastq'
		],
	);

	# Count file to be generated
	my $count_file = $self->prefix . '_counts.tsv';

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
			my $pid = shift;
			push @child_pid => $pid;
		}
	);

	# Count the overall cumulative number of reads for each seqid
	my %counters;

	# Run in parent right after finishing child process
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $counter_ref) = @_;
			while (my ($seqid, $count) = each %$counter_ref) {
				$counters{$seqid} += $count;
			}
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
		push @tmp_files => @files_t;
		my $pid = $pm->start and next;

		#-------------------------------------------------------------------------------
		# Inside child
		#-------------------------------------------------------------------------------
		# Intelace child/parent processes
		my $sig = App::SimulateReads::InterlaceProcesses->new(foreign_pid => [$parent_pid]);

		# Set child seed
		$self->_set_seed($tid);

		# Calculate the number of reads to this job and correct this local index
		# to the global index
		my $number_of_reads_t = int($number_of_reads/$number_of_jobs);
		my $last_read_idx = $number_of_reads_t * $tid;
		my $idx = $last_read_idx - $number_of_reads_t + 1;

		# If it is the last job, make it work on the leftover reads of int() truncation
		$last_read_idx += $number_of_reads % $number_of_jobs
			if $tid == $number_of_jobs;

		log_msg "  => Job $tid: Working on sequences from $idx to $last_read_idx";

		# Create temporary files
		log_msg "  => Job $tid: Creating temporary file: @files_t";
		my @fhs = map { $self->my_open_w($_, $self->output_gzip) } @files_t;

		# Count the cumulative number of reads for each seqid
		my %counter;

		# Run simualtion in child
		for (my $i = $idx; $i <= $last_read_idx and not $sig->signal_catched; $i++) {
			my $id = $seqid->();
			my @fastq_entry;
			try {
				@fastq_entry = $self->sprint_fastq($tid, $i, $id,
					\$fasta->{$id}{seq}, $fasta->{$id}{size}, $strand->());
			} catch {
				die "Not defined entry for seqid '>$id' at job $tid: $_";
			} finally {
				unless (@_) {
					for my $fh_idx (0..$#fhs) {
						$counter{$id}++;
						$fhs[$fh_idx]->say(${$fastq_entry[$fh_idx]})
							or die "Cannot write to $files_t[$fh_idx]: $!\n";
					}
				}
			};
		}

		log_msg "  => Job $tid: Writing and closing file: @files_t";
		# Close temporary files
		for my $fh_idx (0..$#fhs) {
			$fhs[$fh_idx]->close
				or die "Cannot write file $files_t[$fh_idx]: $!\n";
		}

		# Child exit
		log_msg "  => Job $tid is finished";
		$pm->finish(0, \%counter);
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
			or die "Cannot concatenate $tmp_files[$i] to $files{$fastq_class}[$fh_idx]: $!\n";
	}

	# Close files
	log_msg ":: Writing and closing output file: @{ $files{$fastq_class} }";
	for my $fh_idx (0..$#fh) {
		$fh[$fh_idx]->close
			or die "Cannot write file $files{$fastq_class}[$fh_idx]: $!\n";
	}

	# Save counts
	log_msg ":: Saving count file ...";
	my $count_fh = $self->my_open_w($count_file, 0);

	log_msg ":; Wrinting counts to $count_file ...";
	while (my ($id, $count) = each %counters) {
		$count_fh->say("$id\t$count");
	}

	# Just in case, calculate 'gene' like expression
	my $parent_count = $self->_calculate_parent_count(\%counters);

	if (defined $parent_count) {
		while (my ($id, $count) = each %$parent_count) {
			$count_fh->say("$id\t$count");
		}
	}

	# Close $count_file
	log_msg ":; Writing and closing $count_file ...";
	$count_fh->close
		or die "Cannot write file $count_file: $!\n";

	# Clean up the mess
	log_msg ":: Removing temporary files ...";
	for my $file_t (@tmp_files) {
		unlink $file_t
			or die "Cannot remove temporary file: $file_t: $!\n";
	}
}
