package App::Sandy::Role::Digest;
# ABSTRACT: Wrapper on Simulator class for genome/transcriptome sequencing

use App::Sandy::Base 'role';
use App::Sandy::DB::Handle::Quality;
use App::Sandy::DB::Handle::Expression;
use App::Sandy::DB::Handle::Variation;
use App::Sandy::Seq::SingleEnd;
use App::Sandy::Seq::PairedEnd;
use App::Sandy::Simulator;
use Path::Class 'file';
use File::Path 'make_path';
use List::Util 'uniq';

requires qw/default_opt opt_spec rm_opt/;

# VERSION

use constant {
	COUNT_LOOPS_BY_OPT    => ['coverage', 'number-of-reads'],
	STRAND_BIAS_OPT       => ['random', 'plus', 'minus'],
	SEQID_WEIGHT_OPT      => ['length', 'same', 'count'],
	SEQUENCING_TYPE_OPT   => ['single-end', 'paired-end'],
	OUTPUT_FORMAT_OPT     => ['fastq', 'fastq.gz', 'sam', 'bam']
};

override 'opt_spec' => sub {
	my $self = shift;
	my @rm_opt = $self->rm_opt;

	my %all_opt = (
		'seed'                       => 'seed|s=i',
		'prefix'                     => 'prefix|p=s',
		'id'                         => 'id|I=s',
		'append-id'                  => 'append-id|i=s',
		'output-format'              => 'output-format|O=s',
		'compression-level'          => 'compression-level|x=i',
		'join-paired-ends'           => 'join-paired-ends|1',
		'verbose'                    => 'verbose|v',
		'output-dir'                 => 'output-dir|o=s',
		'jobs'                       => 'jobs|j=i',
		'coverage'                   => 'coverage|c=f',
		'read-mean'                  => 'read-mean|m=i',
		'read-stdd'                  => 'read-stdd|d=i',
		'fragment-mean'              => 'fragment-mean|M=i',
		'fragment-stdd'              => 'fragment-stdd|D=i',
		'sequencing-error'           => 'sequencing-error|e=f',
		'sequencing-type'            => 'sequencing-type|t=s',
		'quality-profile'            => 'quality-profile|q=s',
		'strand-bias'                => 'strand-bias|b=s',
		'seqid-weight'               => 'seqid-weight|w=s',
		'number-of-reads'            => 'number-of-reads|n=i',
		'expression-matrix'          => 'expression-matrix|f=s',
		'genomic-variation'          => 'genomic-variation|a=s@',
		'genomic-variation-regex'    => 'genomic-variation-regex|A=s@'
	);

	for my $opt (@rm_opt) {
		delete $all_opt{$opt} if exists $all_opt{$opt};
	}

	return super, values %all_opt;
};

sub _log_msg_opt {
	my ($self, $opts) = @_;
	while (my ($key, $value) = each %$opts) {
		next if ref($value) =~ /Seq/;
		next if $key eq 'argv';
		next if not defined $value;

		$key =~ s/_/ /g;

		if (ref $value eq 'ARRAY') {
			$value = join ', ' => @$value;
		}

		log_msg "  => $key $value";
	}
}

sub _quality_profile_report {
	state $report = App::Sandy::DB::Handle::Quality->new->make_report;
	return $report;
}

sub _expression_matrix_report {
	state $report = App::Sandy::DB::Handle::Expression->new->make_report;
	return $report;
}

sub _genomic_variation_report {
	state $report = App::Sandy::DB::Handle::Variation->new->make_report;
	return $report;
}

sub validate_args {
	my ($self, $args) = @_;
	my $fasta_file = shift @$args;

	# Mandatory fasta file
	if (not defined $fasta_file) {
		die "Missing fasta file\n";
	}

	# Is it really a file?
	if (not -f $fasta_file) {
		die "<$fasta_file> is not a file. Please, give me a valid fasta file\n";
	}

	# Check the file extension: fasta, fa, fna, ffn followed, or not, by .gz
	if ($fasta_file !~ /.+\.(fasta|fa|fna|ffn)(\.gz)?$/) {
		die "<$fasta_file> does not seem to be a fasta file. Please check the file extension\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my $progname = $self->progname;
	my %default_opt = $self->default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Possible alternatives
	my %STRAND_BIAS          = map { $_ => 1 } @{ &STRAND_BIAS_OPT     };
	my %SEQID_WEIGHT         = map { $_ => 1 } @{ &SEQID_WEIGHT_OPT    };
	my %SEQUENCING_TYPE      = map { $_ => 1 } @{ &SEQUENCING_TYPE_OPT };
	my %COUNT_LOOPS_BY       = map { $_ => 1 } @{ &COUNT_LOOPS_BY_OPT  };
	my %OUTPUT_FORMAT        = map { $_ => 1 } @{ &OUTPUT_FORMAT_OPT   };
	my %QUALITY_PROFILE      = %{ $self->_quality_profile_report      };
	my %EXPRESSION_MATRIX    = %{ $self->_expression_matrix_report    };
	my %STRUCTURAL_VARIATION = %{ $self->_genomic_variation_report };

	#  prefix
	if ($opts->{prefix} =~ /([\/\\])/) {
		die "Invalid character in 'prefix' option: $opts->{prefix} => '$1'\n";
	}

	# jobs > 0
	if ($opts->{jobs} <= 0) {
		die "Option 'jobs' requires an integer greater than zero, not $opts->{jobs}\n";
	}

	# quality_profile
	# If the quality_profile is 'poisson', then check the read-mean and rad-stdd.
	# Else look for the quality-profile into the database
	if ($opts->{'quality-profile'} eq 'poisson') {
		if (0 >= $opts->{'read-mean'}) {
			die "Option 'read-mean' requires an integer greater than zero, not $opts->{'read-mean'}\n";
		}

		if (0 > $opts->{'read-stdd'}) {
			die "Option 'read-stdd' requires an integer greater or equal to zero, not $opts->{'read-stdd'}\n";
		}

		# 0 <= sequencing_error <= 1
		if (0 > $opts->{'sequencing-error'} || $opts->{'sequencing-error'} > 1)  {
			die "Option 'sequencing-error' requires a value between zero and one, not $opts->{'sequencing-error'}\n";
		}
	} else {
		if (%QUALITY_PROFILE && exists $QUALITY_PROFILE{$opts->{'quality-profile'}}) {
			my $entry = $QUALITY_PROFILE{$opts->{'quality-profile'}};
			# It is necessary for the next validations, so
			# I set the opts read-size for the value that will be used
			# afterwards
			$opts->{'read-mean'} = $entry->{'mean'};
			$opts->{'read-stdd'} = $entry->{'stdd'};
			$opts->{'sequencing-error'} = $entry->{'error'};
			$opts->{'sequencing-type'} = 'single-end' if $entry->{'type'} eq 'single-molecule';
		} else {
			die "Option quality-profile='$opts->{'quality-profile'}' does not exist into the database.\n",
				"Please check '$progname quality' to see the available profiles or use '--quality-profile=poisson'\n";
		}
	}

	# genomic-variation
	if (exists $opts->{'genomic-variation'}) {
		for my $sv (split(/,/ => join(',', @{ $opts->{'genomic-variation'} }))) {
			unless (%STRUCTURAL_VARIATION && exists $STRUCTURAL_VARIATION{$sv}) {
				die "Option genomic-variation='$sv' does not exist into the database.\n",
					"Please check '$progname variation' to see the available genomic variations\n";
			}
		}
	}

	# genomic-variation-regex
	if (exists $opts->{'genomic-variation-regex'}) {
		for my $sv_pattern (split(/,/ => join(',', @{ $opts->{'genomic-variation-regex'} }))) {
			my $pattern = qr/$sv_pattern/;
			my $fail = 1;
			for my $sv (keys %STRUCTURAL_VARIATION) {
				if ($sv =~ /$pattern/)	 {
					$fail = 0;
					last;
				}
			}

			if ($fail) {
				die "Option genomic-variation-regex='$sv_pattern' does not exist into the database.\n",
					"Please check '$progname variation' to see the available genomic variations\n";
			}
		}
	}

	# strand_bias (STRAND_BIAS_OPT)
	if (not exists $STRAND_BIAS{$opts->{'strand-bias'}}) {
		my $opt = join ', ' => keys %STRAND_BIAS;
		die "Option 'strand-bias' requires one of these arguments: $opt. Not $opts->{'strand-bias'}\n";
	}

	# sequencing_type (SEQUENCING_TYPE_OPT)
	if (not exists $SEQUENCING_TYPE{$opts->{'sequencing-type'}}) {
		my $opt = join ', ' => keys %SEQUENCING_TYPE;
		die "Option 'sequencing-type' requires one of these arguments: $opt not $opts->{'sequencing-type'}\n";
	}

	## Dependently validated arguments
	# fragment_mean and fragment_stdd
	if ($opts->{'sequencing-type'} eq 'paired-end') {
		# fragment_mean > 0
		if ($opts->{'fragment-mean'} <= 0) {
			die "Option 'fragment-mean' requires an integer greater than zero, not $opts->{'fragment-mean'}\n";
		}

		# fragment_stdd > 0
		if ($opts->{'fragment-stdd'} < 0) {
			die "Option 'fragment-stdd' requires an integer greater or equal to zero, not $opts->{'fragment-stdd'}\n";
		}

		# (fragment_mean - fragment_stdd) >= read_mean + read_stdd
		if (($opts->{'fragment-mean'} - $opts->{'fragment-stdd'}) < ($opts->{'read-mean'} + $opts->{'read-stdd'})) {
			die "Option 'fragment-mean' minus 'fragment-stdd' requires a value greater or equal 'read-mean' plus 'read-stdd', not " .
				($opts->{'fragment-mean'} - $opts->{'fragment-stdd'}) . "\n";
		}
	}

	# count-loops-by (COUNT_LOOPS_BY_OPT). The default value is defined into the consuming class
	if (not exists $COUNT_LOOPS_BY{$default_opt{'count-loops-by'}}) {
		my $opt = join ', ' => keys %COUNT_LOOPS_BY;
		die "The provider must define the default count-lopps-by: $opt, not $default_opt{'count-loops-by'}";
	}

	# If default is 'coverage'
	if ($default_opt{'count-loops-by'} eq 'coverage') {
		if (not defined $opts->{coverage}) {
			die "The provider must define the 'coverage' if count-loop-by = coverage";
		}
	}

	if (defined $opts->{coverage} && $opts->{coverage} <= 0) {
		die "Option 'coverage' requires a value greater than zero, not $opts->{coverage}\n";
	}

	# If default is 'number-of-reads'
	if ($default_opt{'count-loops-by'} eq 'number-of-reads') {
		if (not defined $opts->{'number-of-reads'}) {
			die "The provider must define the 'number-of-reads' if count-loop-by = number-of-reads";
		}
	}

	if (defined $opts->{'number-of-reads'} && $opts->{'number-of-reads'} <= 0) {
		die "Option 'number-of-reads' requires a value greater than zero, not $opts->{'number-of-reads'}\n";
	}

	if (not exists $OUTPUT_FORMAT{$opts->{'output-format'}}) {
		my $opt = join ', ' => keys %OUTPUT_FORMAT;
		die "Option 'output-format' requires one of these arguments: $opt not $opts->{'output-format'}\n";
	}

	if ($opts->{'compression-level'} !~ /^[1-9]$/) {
		die "Option 'compression-level' requires an integer between 1-9, not $opts->{'compression-level'}\n";
	}

	# seqid-weight (SEQID_WEIGHT_OPT)
	if (not exists $SEQID_WEIGHT{$opts->{'seqid-weight'}}) {
		my $opt = join ', ' => keys %SEQID_WEIGHT;
		die "Option 'seqid-weight' requires one of these arguments: $opt not $opts->{'seqid_weight'}\n";
	}

	# Now expression-matrix is an option
	if ($opts->{'expression-matrix'}) {
		$opts->{'seqid-weight'} = 'count';
	}

	# seqid-weight eq 'count' requires an expression-matrix
	if ($opts->{'seqid-weight'} eq 'count') {
		if (not defined $opts->{'expression-matrix'}) {
			die "Option 'expression-matrix' requires a database entry\n";
		}

		# It is defined, but the entry exists?
		unless (%EXPRESSION_MATRIX && exists $EXPRESSION_MATRIX{$opts->{'expression-matrix'}}) {
			die "Option expression-matrix='$opts->{'expression-matrix'}' does not exist into the database.\n",
				"Please check '$progname expression' to see the available matrices\n";
		}
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $fasta_file = shift @$args;

	my %default_opt = $self->default_opt;
	$self->fill_opts($opts, \%default_opt);

	my $report = $self->_quality_profile_report;
	my $entry = $report->{$opts->{'quality-profile'}};

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Override default 'count-loops-by'
	if ($default_opt{'count-loops-by'} eq 'coverage') {
		$opts->{'count-loops-by'} = 'number-of-reads' if exists $opts->{'number-of-reads'};
	}
	elsif ($default_opt{'count-loops-by'} eq 'number-of-reads') {
		$opts->{'count-loops-by'} = 'coverage' if exists $opts->{'coverage'};
	} else {
		die "'count-lopps-by' must be defined"
	}

	# Now expression-matrix is an option
	if ($opts->{'expression-matrix'}) {
		$opts->{'seqid-weight'} = 'count';
	}

	# Override read-size if quality-profile comes from database
	if ($opts->{'quality-profile'} ne 'poisson') {
		# Override default or user-defined value
		$opts->{'read-mean'} = $entry->{'mean'};
		$opts->{'read-stdd'} = $entry->{'stdd'};
		$opts->{'sequencing-error'} = $entry->{'error'};
		$opts->{'sequencing-type'} = 'single-end' if $entry->{'type'} eq 'single-molecule';
	}

	# Sequence identifier
	$opts->{'id'} ||= $opts->{'sequencing-type'} eq 'paired-end'
		? $opts->{'paired-end-id'}
		: $opts->{'single-end-id'};

	# Append extra id
	$opts->{'id'} .= " $opts->{'append-id'}" if defined $opts->{'append-id'};

	# If bam, leave only the first field;
	if ($opts->{'output-format'} =~ /^(bam|sam)$/) {
		$opts->{'id'} = (split ' ' => $opts->{'id'})[0];
	}

	# In this case, try to make simulation less redundant
	if ($opts->{'output-format'} =~ /fastq/ && $opts->{'sequencing-type'} eq 'paired-end'
		&& $opts->{'join-paired-ends'}) {
		# Try to guess if the user passed a char to distinguish single/paired-end reads
		$opts->{'id'} =~ /%R/ || $opts->{'id'} =~ s/(\S+)/$1\/\%R/;
	}

	# Structural Variation
	if ($opts->{'genomic-variation'}) {
		my @svs = split(/,/ => join(',', @{ $opts->{'genomic-variation'} }));
		@svs = uniq sort @svs;
		$opts->{'genomic-variation'} = \@svs;
	}

	# Structural Variation Regex
	if ($opts->{'genomic-variation-regex'}) {
		my @sv_list = keys %{ $self->_genomic_variation_report };
		my @sv_patterns = split(/,/ => join(',', @{ $opts->{'genomic-variation-regex'} }));
		my @svs_rg;

		for my $sv_pattern (@sv_patterns) {
			my $pattern = qr/$sv_pattern/;
			for (@sv_list) {
				if (/$pattern/)	{
					push @svs_rg => $_;
				}
			}
		}

		my @svs;

		if ($opts->{'genomic-variation'}) {
			push @svs => @{ $opts->{'genomic-variation'} };
		}

		push @svs => @svs_rg;
		@svs = uniq sort @svs;
		$opts->{'genomic-variation'} = \@svs;
	}

	# Create output directory if it not exist
	make_path($opts->{'output-dir'}, {error => \my $err_list});
	my $err_dir;
	if (@$err_list) {
		for (@$err_list) {
			my ($dir, $message) = %$_;
			$err_dir .= "Problem creating '$dir': $message\n";
		}
		die "$err_dir\n";
	}

	# Concatenate output-dir to prefix
	my $prefix = file($opts->{'output-dir'}, $opts->{prefix});
	$opts->{prefix} = "$prefix";

	#-------------------------------------------------------------------------------
	#  Log presentation header
	#-------------------------------------------------------------------------------
	my $time_stamp = localtime;
	my $progname = $self->progname;
	my $argv = $self->argv;
	log_msg <<"HEADER";
--------------------------------------------------------
$progname - $time_stamp
--------------------------------------------------------
:: Arguments passed by the user:
  => '@$argv'
HEADER

	#-------------------------------------------------------------------------------
	#  Construct the Seq and Simulator classes
	#-------------------------------------------------------------------------------
	my %paired_end_param = (
		template_id       => $opts->{'id'},
		format            => $opts->{'output-format'},
		quality_profile   => $opts->{'quality-profile'},
		sequencing_error  => $opts->{'sequencing-error'},
		read_mean         => $opts->{'read-mean'},
		read_stdd         => $opts->{'read-stdd'},
		fragment_mean     => $opts->{'fragment-mean'},
		fragment_stdd     => $opts->{'fragment-stdd'}
	);

	my %single_end_param = (
		template_id       => $opts->{'id'},
		format            => $opts->{'output-format'},
		quality_profile   => $opts->{'quality-profile'},
		sequencing_error  => $opts->{'sequencing-error'},
		read_mean         => $opts->{'read-mean'},
		read_stdd         => $opts->{'read-stdd'}
	);

	my $seq;
	if ($opts->{'sequencing-type'} eq 'paired-end') {
		log_msg ":: Creating paired-end seq generator ...";
		$self->_log_msg_opt(\%paired_end_param);
		$seq = App::Sandy::Seq::PairedEnd->new(%paired_end_param);
	} else {
		log_msg ":: Creating single-end seq generator ...";
		$self->_log_msg_opt(\%single_end_param);
		$seq = App::Sandy::Seq::SingleEnd->new(%single_end_param);
	}

	my %simulator_param = (
		argv                 => $argv,
		seq                  => $seq,
		fasta_file           => $fasta_file,
		truncate             => $entry->{'type'} && $entry->{'type'} eq 'single-molecule',
		prefix               => $opts->{'prefix'},
		output_format        => $opts->{'output-format'},
		compression_level    => $opts->{'compression-level'},
		join_paired_ends     => $opts->{'join-paired-ends'},
		seed                 => $opts->{'seed'},
		count_loops_by       => $opts->{'count-loops-by'},
		number_of_reads      => $opts->{'number-of-reads'},
		coverage             => $opts->{'coverage'},
		jobs                 => $opts->{'jobs'},
		strand_bias          => $opts->{'strand-bias'},
		seqid_weight         => $opts->{'seqid-weight'},
		expression_matrix    => $opts->{'expression-matrix'},
		genomic_variation    => $opts->{'genomic-variation'}
	);

	my $simulator;
	log_msg ":: Creating simulator ...";
	$self->_log_msg_opt(\%simulator_param);
	$simulator = App::Sandy::Simulator->new(%simulator_param);

	#-------------------------------------------------------------------------------
	#  Let's simulate it!
	#-------------------------------------------------------------------------------
	log_msg ":: Running simulation ...";
	$simulator->run_simulation;

	log_msg ":: End simulation. So long, and thanks for all the fish!";
}
