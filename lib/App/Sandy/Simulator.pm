package App::Sandy::Simulator;
# ABSTRACT: Class responsible to make the simulation

use App::Sandy::Base 'class';
use App::Sandy::Seq::SingleEnd;
use App::Sandy::Seq::PairedEnd;
use App::Sandy::InterlaceProcesses;
use App::Sandy::WeightedRaffle;
use App::Sandy::PieceTable;
use App::Sandy::DB::Handle::Expression;
use App::Sandy::DB::Handle::Variation;
use List::Util 'min';
use File::Cat 'cat';
use Parallel::ForkManager;

with qw/App::Sandy::Role::IO App::Sandy::Role::SeqID/;

# VERSION

has 'argv' => (
	is       => 'ro',
	isa      => 'ArrayRef[Str]',
	required => 1
);

has 'truncate' => (
	is       => 'ro',
	isa      => 'Bool',
	required => 1
);

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

has 'join_paired_ends' => (
	is         => 'ro',
	isa        => 'Bool',
	required   => 1
);

has 'output_format' => (
	is          => 'ro',
	isa         => 'My:Format',
	required    => 1
);

has 'compression_level' => (
	is          => 'ro',
	isa         => 'My:Level',
	required    => 1
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

has 'genomic_variation' => (
	is         => 'ro',
	isa        => 'ArrayRef[Str]',
	required   => 0
);

has '_genomic_variation_names' => (
	is         => 'ro',
	isa        => 'Maybe[Str]',
	builder    => '_build_genomic_variation_names',
	lazy_build => 1
);

has 'seq' => (
	is         => 'ro',
	isa        => 'App::Sandy::Seq::SingleEnd | App::Sandy::Seq::PairedEnd',
	required   => 1,
	handles    => [ qw{ sprint_seq gen_sam_header gen_eof_marker } ]
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

has '_seqname' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[Str]',
	default    => sub { {} },
	handles    => {
		_set_seqname => 'set',
		_get_seqname => 'get'
	}
);

has '_piece_table' => (
	is         => 'ro',
	isa        => 'HashRef[HashRef[My:PieceTable]]',
	builder    => '_build_piece_table',
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

	# If seqid_weight is 'count', then expression_matrix must be defined
	if ($self->seqid_weight eq 'count' and not defined $self->expression_matrix) {
		croak "seqid_weight=count requires a expression_matrix\n";
	}

	# If count_loops_by is 'coverage', then coverage must be defined. Else if
	# it is equal to 'number_of_reads', then number_of_reads must be defined
	if ($self->count_loops_by eq 'coverage' and not defined $self->coverage) {
		croak "count_loops_by=coverage requires a coverage number\n";
	} elsif ($self->count_loops_by eq 'number_of_reads' and not defined $self->number_of_reads) {
		croak "count_loops_by=number_of_reads requires a number_of_reads number\n";
	}

	## Just to ensure that the lazy attributes are built before &new returns
	$self->_piece_table;
	$self->_seqid_raffle;
	$self->_fasta;
	$self->_strand;
}

sub _build_strand {
	my $self = shift;
	my $strand_sub;

	if ($self->strand_bias eq 'plus') {
		$strand_sub = sub {1};
	} elsif ($self->strand_bias eq 'minus') {
		$strand_sub = sub {0};
	} elsif ($self->strand_bias eq 'random') {
		$strand_sub = sub { int(rand(2)) };
	} else {
		croak sprintf "Unknown option '%s' for strand bias\n",
			$self->strand_bias;
	}

	return $strand_sub;
}

sub _index_fasta {
	my $self = shift;
	my $fasta = $self->fasta_file;

	my $fh = $self->with_open_r($fasta);

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

			# Seq ID standardization in order to manage comparations
			# between chr1, Chr1, CHR1, 1 etc;
			my $std_id = $self->with_std_seqid($id);
			$self->_set_seqname(
				$id     => $std_id,
				$std_id => $id
			);

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

	unless ($self->truncate) {
		for my $id (keys %$indexed_fasta) {
			my $index_size = $indexed_fasta->{$id}{size};
			my $class = ref $self->seq;

			if ($class eq 'App::Sandy::Seq::SingleEnd') {
				my $read_mean = $self->seq->read_mean;
				if ($index_size < $read_mean) {
					log_msg ":: Parsing fasta file '$fasta': Seqid sequence length (>$id => $index_size) lesser than required read mean ($read_mean)";
					delete $indexed_fasta->{$id};
					push @blacklist => $id;
				}
			} elsif ($class eq 'App::Sandy::Seq::PairedEnd') {
				my $fragment_mean = $self->seq->fragment_mean;
				if ($index_size < $fragment_mean) {
					log_msg ":: Parsing fasta file '$fasta': Seqid sequence length (>$id => $index_size) lesser than required fragment mean ($fragment_mean)";
					delete $indexed_fasta->{$id};
					push @blacklist => $id;
				}
			} else {
				croak "Unknown option '$class' for sequencing type\n";
			}
		}
	}

	unless (%$indexed_fasta) {
		die sprintf "Fasta file '%s' has no valid entry\n" => $self->fasta_file;
	}

	# If fasta_rtree has entries
	unless ($self->_has_no_fasta_rtree) {
		# Remove no valid entries from id -> pid relation
		$self->_delete_fasta_rtree(@blacklist) if @blacklist;
	}

	return $indexed_fasta;
}

sub _populate_fasta_tree {
	my $self = shift;

	# If fasta_rtree has entries
	unless ($self->_has_no_fasta_rtree) {
		# Build parent -> child ids relation
		my %fasta_tree;

		# Reverse fasta_rtree to pid -> \@ids
		for my $pair ($self->_fasta_rtree_pairs) {
			my ($id, $pid) = (@$pair);
			push @{ $fasta_tree{$pid} } => $id;
		}

		$self->_set_fasta_tree(%fasta_tree);
	}
}

sub _retrieve_expression_matrix {
	my $self = shift;
	my $expression = App::Sandy::DB::Handle::Expression->new;
	return $expression->retrievedb($self->expression_matrix);
}

sub _build_seqid_raffle {
	my $self = shift;

	# Get the piece table
	my $piece_table = $self->_piece_table;

	# The builded function
	my $seqid_sub;

	if ($self->seqid_weight eq 'same') {
		my ($keys, $weights) = $self->_populate_key_weight($piece_table, sub { 1 });

		# If weight == 1 means that there are 2 keys for
		# the same seq_id.
		# If weight == 2 means that there is only one key
		# for the seq_id, so I double that key
		for (my $i = 0; $i < @$weights; $i++) {
			if ($weights->[$i] > 1) {
				push @$keys => $keys->[$i];
			}
		}

		my $keys_size = scalar @$keys;
		$seqid_sub = sub { $keys->[int(rand($keys_size))] };
	} elsif ($self->seqid_weight eq 'count') {
		# Catch expression-matrix entry from database
		my $indexed_file = $self->_retrieve_expression_matrix;

		# Catch indexed fasta
		my $indexed_fasta = $self->_fasta;

		# Validate expression_matrix
		for my $id (keys %$indexed_file) {
			# If not exists into indexed_fasta, it must then exist into fasta_tree
			unless (exists $piece_table->{$id} || $self->_exists_fasta_tree($id)) {
				log_msg sprintf ":: Ignoring seqid '%s' from expression-matrix '%s': It is not found into the indexed fasta"
					=> $id, $self->expression_matrix;
				delete $indexed_file->{$id};
			}
		}

		unless (%$indexed_file) {
			die sprintf "No valid seqid entry of the expression-matrix '%s' is recorded into the indexed fasta\n"
				=> $self->expression_matrix;
		}

		my (%ptable_ind, %ptable_cluster);

		# Split indexed_file seq_ids between those
		# into piece_table and those that represents a cluster
		# of seq_ids as in gene -> transcript relationship
		for my $seq_id (keys %$indexed_file) {
			if (exists $piece_table->{$seq_id}) {
				$ptable_ind{$seq_id} = $piece_table->{$seq_id};

			} else {
				my $ids = $self->_get_fasta_tree($seq_id);

				# Bug catcher
				unless (@$ids) {
					croak "seq_id '$seq_id' not found into piece_table";
				}

				$ptable_cluster{$seq_id} = $ids;
			}
		}

		# Let's calculate the weight taking in acount
		# the size  increase/decrease
		my $calc_ind_weight = sub {
			my ($seq_id, $type) = @_;

			my $counts = $indexed_file->{$seq_id};
			my $size = $piece_table->{$seq_id}{$type}{size};
			my $fasta_size = $indexed_fasta->{$seq_id}{size};

			# Correct the weight according to the
			# genomic variation change by the ratio
			# between the table size and fasta size
			my $factor = $size / $fasta_size;

			return $counts * $factor;
		};

		my ($keys, $weights);

		if (%ptable_ind) {
			($keys, $weights) = $self->_populate_key_weight(\%ptable_ind,
				$calc_ind_weight);
		}

		# If there are seq_id cluster like, then its is
		# time to calculate these weights
		for my $seq_id (sort keys %ptable_cluster) {
			my %ptable;

			# Slice piece_table hash
			my $ids = $ptable_cluster{$seq_id};
			@ptable{@$ids} = @$piece_table{@$ids};

			# total size among all ids of cluster
			my %total;

			# Calculate the total size by type
			for my $type_h (values %ptable) {
				for my $type (keys %$type_h) {
					$total{$type} += $type_h->{$type}{size};
				}
			}

			# Calculate the weight taking in acount the size increase/decrease
			# and the ratio between the total size by type and the table size.
			# The problem here is that I must divide the 'counts' for some 'seq_id'
			# among all ids that belong to it
			my $calc_cluster_weight = sub {
				my ($id, $type) = @_;

				my $counts = $indexed_file->{$seq_id};
				my $size = $piece_table->{$id}{$type}{size};
				my $fasta_size = $indexed_fasta->{$id}{size};

				# Divide the counts among all ids
				my $ratio = $size / $total{$type};

				# Correct the weight according to the size
				my $factor = $size / $fasta_size;

				return $counts * $factor * $ratio;
			};

			my ($k, $w) = $self->_populate_key_weight(\%ptable,
				$calc_cluster_weight);

			push @$keys => @$k;
			push @$weights => @$w;
		}

		unless (@$keys && @$weights) {
			croak "No keys weights have been set";
		}

		# It is very necessary in order
		# to avoid truncation of numbers
		# between zero and one
		$self->_round_weight($weights);

		my $raffler = App::Sandy::WeightedRaffle->new(
			'weights' => $weights,
			'keys'    => $keys
		);

		$seqid_sub = sub { $raffler->weighted_raffle };
	} elsif ($self->seqid_weight eq 'length') {
		my $calc_weight = sub {
			my ($seq_id, $type) = @_;
			return $piece_table->{$seq_id}{$type}{size};
		};

		my ($keys, $weights) = $self->_populate_key_weight($piece_table,
			$calc_weight);

		# Just in case ...
		$self->_round_weight($weights);

		my $raffler = App::Sandy::WeightedRaffle->new(
			weights => $weights,
			keys    => $keys
		);

		$seqid_sub = sub { $raffler->weighted_raffle };
	} else {
		croak sprintf "Unknown option '%s' for seqid_weight\n",
			$self->seqid_weight;
	}

	return $seqid_sub;
}

sub _round_weight {
	my ($self, $weights) = @_;

	my $min = min @$weights;

	if ($min <= 0) {
		croak "min weight le to zero: $min";
	}

	my $factor = $min < 1
		? (1 / $min)
		: 1;

	for my $weight (@$weights) {
		$weight = int($weight * $factor + 0.5);
	}
}

sub _populate_key_weight {
	my ($self, $piece_table, $calc_weight) = @_;

	my (@keys, @weights);

	# It needs to be sorted in order to the
	# seed works
	for my $seq_id (sort keys %$piece_table) {
		my $type_h = $piece_table->{$seq_id};

		# If there is no alternative seq_id, then
		# set a factor to correct the size.
		# It is necessary because the seq_ids with
		# alternative and reference will double its
		# own coverage
		my $factor = scalar keys %$type_h == 1
			? 2
			: 1;

		for my $type (sort keys %$type_h) {

			my %key = (
				'seq_id' => $seq_id,
				'type'   => $type
			);

			my $weight = $calc_weight->($seq_id, $type);

			push @keys => \%key;
			push @weights => $weight * $factor;
		}
	}

	return (\@keys, \@weights);
}

sub _build_genomic_variation_names {
	my $self = shift;
	if ($self->genomic_variation) {
		return sprintf "[%s]", => join ", ", @{ $self->genomic_variation };
	}
}

sub _retrieve_genomic_variation {
	my $self = shift;
	my $variation = App::Sandy::DB::Handle::Variation->new;
	return $variation->retrievedb($self->genomic_variation);
}

sub _build_piece_table {
	my $self = shift;

	my $genomic_variation = $self->_genomic_variation_names;
	my $indexed_snv;

	# Retrieve genomic variation if the user provided it
	if (defined $genomic_variation) {
		$indexed_snv = $self->_retrieve_genomic_variation;
		log_msg ":: Validate genomic variation '$genomic_variation' against indexed fasta ...";
		$self->_validate_indexed_snv_against_fasta($indexed_snv);
	}

	# Catch index fasta
	my $indexed_fasta = $self->_fasta;

	# Build piece table
	my %piece_table;

	# Let's construct the piece_table
	log_msg ":: Build piece table ...";

	while (my ($seq_id, $fasta_h) = each %$indexed_fasta) {
		my $seq = \$fasta_h->{seq};
		my $std_seq_id = $self->_get_seqname($seq_id);

		# Initialize piece tables for $seq_id ref
		$piece_table{$seq_id}{ref}{table} = App::Sandy::PieceTable->new(orig => $seq);

		# If there is indexed_snv for seq_id, then construct the piece table with it
		if (defined $indexed_snv && defined $indexed_snv->{$std_seq_id}) {
			my $snvs = $indexed_snv->{$std_seq_id};

			# Filter only the homozygotic snvs to feed reference seq_id
			my @snvs_homo = grep { $_->{plo} eq 'HO' } @$snvs;

			if (@snvs_homo) {
				# Populate reference seq_id
				$self->_populate_piece_table($piece_table{$seq_id}{ref}{table}, \@snvs_homo);
			}

			# Initialize piece tables for $seq_id alt
			$piece_table{$seq_id}{alt}{table} = App::Sandy::PieceTable->new(orig => $seq);

			# Populate alternative seq_id
			$self->_populate_piece_table($piece_table{$seq_id}{alt}{table}, $snvs);
		}
	}

	# Initialize the logical offsets and valodate the
	# new size due to the genomic variation

	my @blacklist;

	for my $seq_id (keys %piece_table) {
		my $type_h = delete $piece_table{$seq_id};

		for my $type (keys %$type_h) {
			my $table_h = delete $type_h->{$type};
			my $table = $table_h->{table};

			# Initialize the logical offset
			$table->calculate_logical_offset;

			# Get the new size
			my $new_size = $table->logical_len;

			unless ($self->truncate) {
				my $class = ref $self->seq;

				if ($class eq 'App::Sandy::Seq::SingleEnd') {
					if ($new_size < $self->seq->read_mean) {
						log_msg ":: Skip '$seq_id:$type': So many deletions resulted in a sequence lesser than the required read-mean";
						next;
					}
				} elsif ($class eq 'App::Sandy::Seq::PairedEnd') {
					if ($new_size < $self->seq->fragment_mean) {
						log_msg ":: Skip '$seq_id:$type': So many deletions resulted in a sequence lesser than the required fragment mean";
						next;
					}
				} else {
					die "No valid options for 'seq'";
				}
			}

			# If all's right
			$table_h->{size} = $new_size;
			$type_h->{$type} = $table_h;
		}

		# if there is at least one type,
		# then return it to the piece_table
		if (%$type_h) {
			$piece_table{$seq_id} = $type_h;

		# else, just remove it!
		} else {
			push @blacklist => $seq_id;
		}
	}

	unless (%piece_table) {
		die "All fasta entries were removed due to deletions. ",
			"Please, verify the genomic variation '$genomic_variation'\n";
	}

	# If fasta_rtree has entries
	unless ($self->_has_no_fasta_rtree) {
		# Remove no valid entries from id -> pid relation
		$self->_delete_fasta_rtree(@blacklist) if @blacklist;
	}

	# Make the id -> pid relationship
	$self->_populate_fasta_tree;

	# HASH -> SEQ_ID -> @(REF @ALT) -> @(TABLE SIZE)
	return \%piece_table;
}

sub _populate_piece_table {
	my ($self, $table, $snvs) = @_;

	for my $snv (@$snvs) {
		# If there is an ID, make sure that it is not a comma, colon
		# separated list. Else, make sure to keep the ref/alt length
		# to max 25+25+1=51
		my $annot = defined $snv->{id} && $snv->{id} ne '.'
			? sprintf "%d:%s" => $snv->{pos} + 1, (split(/[,;]/, $snv->{id}))[0]
			: sprintf "%d:%.25s/%.25s" => $snv->{pos} + 1, $snv->{ref}, $snv->{alt};

		# Insertion
		if ($snv->{ref} eq '-') {
			$table->insert(\$snv->{alt}, $snv->{pos}, $annot);

		# Deletion
		} elsif ($snv->{alt} eq '-') {
			$table->delete($snv->{pos}, length $snv->{ref}, $annot);

		# Change
		} else {
			$table->change(\$snv->{alt}, $snv->{pos}, length $snv->{ref}, $annot);
		}
	}
}

sub _validate_indexed_snv_against_fasta {
	my ($self, $indexed_snv) = @_;

	my $indexed_fasta = $self->_fasta;
	my $genomic_variation = $self->_genomic_variation_names;

	for my $std_seq_id (keys %$indexed_snv) {
		my $snvs = delete $indexed_snv->{$std_seq_id};
		my $seq_id = $self->_get_seqname($std_seq_id);

		unless (defined $seq_id && exists $indexed_fasta->{$seq_id}) {
			next;
		}

		my $seq = \$indexed_fasta->{$seq_id}{seq};
		my $size = $indexed_fasta->{$seq_id}{size};

		my @saved_snvs;

		for my $snv (@$snvs) {
			# Insertions may accur until one base after the
			# end of the sequence, not more
			if (($snv->{ref} eq '-' && $snv->{pos} > $size) || ($snv->{ref} ne '-' && $snv->{pos} >= $size)) {
				log_msg sprintf ":: In validating '%s': Position, %s/%s at %s:%d, outside fasta sequence",
					$genomic_variation, $snv->{ref}, $snv->{alt}, $seq_id, $snv->{pos} + 1;

				# Next snv
				next;
			# Deletions and changes. Just verify if the reference exists
			} elsif ($snv->{ref} ne '-') {
				my $ref = substr $$seq, $snv->{pos}, length($snv->{ref});

				if (uc($ref) ne uc($snv->{ref})) {
					log_msg sprintf ":: In validating '%s': Not found reference '%s' at fasta position %s:%d",
						$genomic_variation, $snv->{ref}, $seq_id, $snv->{pos} + 1;

					# Next snv
					next;
				}
			}

			push @saved_snvs  => $snv;
		}

		if (@saved_snvs) {
			$indexed_snv->{$std_seq_id} = [@saved_snvs];
		}
	}
}

sub _calculate_number_of_reads {
	my $self = shift;
	my $number_of_reads;

	if ($self->count_loops_by eq 'coverage') {
		# It is needed to calculate the genome size
		my $fasta = $self->_fasta;
		my $fasta_size = 0;
		$fasta_size += $fasta->{$_}{size} for keys %{ $fasta };
		$number_of_reads = int(($fasta_size * $self->coverage) / $self->seq->read_mean);
		# In case it is paired-end read, divide the number of reads by 2 because
		# App::Sandy::Seq::PairedEnd class returns 2 reads at time
		$number_of_reads = int($number_of_reads / 2)
			if ref($self->seq) eq 'App::Sandy::Seq::PairedEnd';
	} elsif ($self->count_loops_by eq 'number-of-reads') {
		$number_of_reads = $self->number_of_reads;
	} else {
		croak sprintf "Unknown option '%s' for calculating the number of reads\n",
			$self->count_loops_by;
	}

	# Maybe the number_of_reads is zero. It may occur due to the low coverage and/or fasta_file size
	if ($number_of_reads <= 0) {
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
	my $piece_table = $self->_piece_table;

	# Calculate the number of reads to be generated
	my $number_of_reads = $self->_calculate_number_of_reads;

	# Function that returns strand by strand_bias
	my $strand = $self->_strand;

	# Function that returns seqid by seqid_weight
	my $seqid = $self->_seqid_raffle;

	# genome or transcriptome?
	my $simulation = $self->argv->[0];

	# Count file to be generated
	my $count_file = $simulation eq 'transcriptome'
		? $self->prefix . '_abundance.tsv'
		: $self->prefix . '_coverage.tsv';

	# Main files
	my %files = (
		bam                  => [
			$self->prefix . '.bam'
		],
		sam                  => [
			$self->prefix . '.sam'
		],
		single_fastq         => [
			$self->prefix . '_R1_001.fastq'
		],
		single_fastq_gz      => [
			$self->prefix . '_R1_001.fastq.gz'
		],
		join_paired_fastq    => [
			$self->prefix . '.fastq'
		],
		join_paired_fastq_gz => [
			$self->prefix . '.fastq.gz'
		],
		paired_fastq         => [
			$self->prefix . '_R1_001.fastq',
			$self->prefix . '_R2_001.fastq'
		],
		paired_fastq_gz      => [
			$self->prefix . '_R1_001.fastq.gz',
			$self->prefix . '_R2_001.fastq.gz'
		]
	);

	# Set the file class in order to know
	# how to deal with all files options
	my $seq_class = ref $self->seq;
	my $output_format = $self->output_format;
	my $file_class;

	# This mess is necessary to catch the
	# right value into the %files hash
	if ($output_format =~ /(sam|bam)/) {
		$file_class = $output_format;
	} elsif ($output_format =~ /fastq/) {
		if ($seq_class eq 'App::Sandy::Seq::SingleEnd') {
			$file_class = 'single_fastq';
		} elsif ($seq_class eq 'App::Sandy::Seq::PairedEnd') {
			$file_class = 'paired_fastq';
			$file_class = "join_$file_class" if $self->join_paired_ends;
		} else {
			croak "Something wrong with the seq class: $seq_class";
		}
		if ($output_format eq 'fastq.gz') {
			$file_class .= '_gz';
		}
	} else {
		croak "Something wrong with the output format: $output_format";
	}

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
		my @files_t = map { "$_.${parent_pid}.part$tid" } @{ $files{$file_class} };
		push @tmp_files => @files_t;
		my $pid = $pm->start and next;

		#-------------------------------------------------------------------------------
		# Inside child
		#-------------------------------------------------------------------------------
		# Intelace child/parent processes
		my $sig = App::Sandy::InterlaceProcesses->new(foreign_pid => [$parent_pid]);

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

		# And here we go ...
		my @fhs;

		# Set the right filehandle format
		if ($output_format =~ /^(sam|fastq)$/) {
			@fhs = map { $self->with_open_w($_, 0) } @files_t;
		} elsif ($output_format eq 'fastq.gz') {
			@fhs = map { $self->with_open_w($_, $self->compression_level) } @files_t;
		} elsif ($output_format eq 'bam') {
			@fhs = map { $self->with_open_bam_w($_, $self->compression_level) } @files_t;
		} else {
			croak "Something wrong with the output format: $file_class";
		}

		# sprint_seq gives two entries for paired-emd, so
		# if it is a bam|sam|join-paired-ends, it is necessary
		# to copy the filehandle in order to print both entries
		# to the same file
		if ($seq_class eq 'App::Sandy::Seq::PairedEnd'
			&& $file_class =~ /(sam|bam|join)/) {
			$fhs[1] = $fhs[0];
		}

		# Count the cumulative number of reads for each seqid
		my %counter;

		# If the output format is 'bam|sam' and it is the first job, then
		# write the header
		if ($output_format =~ /^(sam|bam)$/ && $tid == 1) {
			my $header_ref = $self->gen_sam_header($self->argv);
			print {$fhs[0]} "$$header_ref";
		}

		# Run simulation in child
		for (my $i = $idx; $i <= $last_read_idx and not $sig->signal_catched; $i++) {
			my $id = $seqid->();
			my $ptable = $piece_table->{$id->{seq_id}}{$id->{type}};
			my @seq_entry;
			try {
				@seq_entry = $self->sprint_seq($tid, $i, $id->{seq_id}, $id->{type},
					$ptable->{table}, $ptable->{size}, $strand->());
			} catch {
				die "Not defined entry for seqid '>$id->{seq_id}' at job $tid: $_";
			} finally {
				unless (@_) {
					for my $fh_idx (0..$#fhs) {
						$counter{$id->{seq_id}}++;
						print {$fhs[$fh_idx]} "${$seq_entry[$fh_idx]}";
					}
				}
			};
		}

		log_msg "  => Job $tid: Writing and closing file: @files_t";

		# Close temporary files
		# Get index from @files_t in order to avoid
		# close the same filehandle twice - When the
		# position 1-N is a copy
		for my $fh_idx (0..$#files_t) {
			close $fhs[$fh_idx];
		}

		# If it is a bam and it is the last loop, then
		# write a eof marker
		if ($output_format eq 'bam' && $tid == $number_of_jobs) {
			$self->gen_eof_marker($files_t[0]);
		}

		# Child exit
		log_msg "  => Job $tid is finished";
		$pm->finish(0, \%counter);
	}

	# Back to parent
	# Interlace parent/child(s) processes
	my $sig = App::Sandy::InterlaceProcesses->new(foreign_pid => \@child_pid);
	$pm->wait_all_children;

	if ($sig->signal_catched) {
		log_msg ":: Termination signal received!";
	}

	log_msg ":: Saving the work ...";

	# Concatenate all temporary files
	log_msg ":: Concatenate all temporary files";

	# Save time. Rename tmp_file (1,2)
	for my $file (@{ $files{$file_class} }) {
		my $tmp = shift @tmp_files;
		log_msg "  => Concatenating $tmp to $file ...";
		rename $tmp => $file
			or die "Cannot create '$file': $!\n";
	}

	# Append to renamed tmp files
	my @fh = map { $self->with_open_a($_) } @{ $files{$file_class} };

	for my $i (0..$#tmp_files) {
		my $fh_idx = $i % scalar @fh;

		log_msg "  => Concatenating $tmp_files[$i] to $files{$file_class}[$fh_idx] ...";
		cat $tmp_files[$i] => $fh[$fh_idx]
			or die "Cannot concatenate $tmp_files[$i] to $files{$file_class}[$fh_idx]: $!\n";

		# Clean up the mess
		unlink $tmp_files[$i]
			or die "Cannot remove temporary file '$tmp_files[$i]': $!\n";
	}

	# Close files
	log_msg ":: Writing and closing output file: @{ $files{$file_class} }";
	for my $fh_idx (0..$#fh) {
		close $fh[$fh_idx]
			or die "Cannot write file $files{$file_class}[$fh_idx]: $!\n";
	}

	# Save counts
	log_msg ":: Saving count file";
	my $count_fh = $self->with_open_w($count_file, 0);

	# It is necessary to correct the abundance according to
	# fragment sequencing end
	my $count_factor = 1;
	if ($self->count_loops_by eq 'number-of-reads'
		&& ref($self->seq) eq 'App::Sandy::Seq::PairedEnd') {
		$count_factor = 2;
	}

	log_msg "  => Writing counts to $count_file ...";
	for my $id (sort keys %counters) {
		printf {$count_fh} "%s\t%d\n" => $id,
			int($counters{$id} / $count_factor);
	}

	# Just in case, calculate 'gene' like expression
	my $parent_count = $self->_calculate_parent_count(\%counters);

	for my $id (sort keys %$parent_count) {
		printf {$count_fh} "%s\t%d\n" => $id,
			int($parent_count->{$id} / $count_factor);
	}

	# Close $count_file
	log_msg ":; Writing and closing $count_file ...";
	close $count_fh
		or die "Cannot write file $count_file: $!\n";
}
