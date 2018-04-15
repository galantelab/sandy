package App::SimulateReads::Role::Digest;
# ABSTRACT: Wrapper on Simulator class for genome/transcriptome sequencing

use App::SimulateReads::Base 'role';
use App::SimulateReads::DB::Handle::Quality;
use App::SimulateReads::DB::Handle::Expression;
use App::SimulateReads::Fastq::SingleEnd;
use App::SimulateReads::Fastq::PairedEnd;
use App::SimulateReads::Simulator;
use Path::Class 'file';
use File::Path 'make_path';

requires qw/default_opt opt_spec rm_opt/;

# VERSION

use constant {
	COUNT_LOOPS_BY_OPT    => ['coverage', 'number-of-reads'],
	STRAND_BIAS_OPT       => ['random', 'plus', 'minus'],
	SEQID_WEIGHT_OPT      => ['length', 'same', 'count'],
	SEQUENCING_TYPE_OPT   => ['single-end', 'paired-end']
};

override 'opt_spec' => sub {
	my $self = shift;
	my @rm_opt = $self->rm_opt;

	my %all_opt = (
		'seed'              => 'seed|s=i',
		'prefix'            => 'prefix|p=s',
		'id'                => 'id|I=s',
		'append-id'         => 'append-id|i=s',
		'verbose'           => 'verbose|v',
		'output-dir'        => 'output-dir|o=s',
		'jobs'              => 'jobs|j=i',
		'gzip'              => 'gzip|z!',
		'coverage'          => 'coverage|c=f',
		'read-size'         => 'read-size|r=i',
		'fragment-mean'     => 'fragment-mean|m=i',
		'fragment-stdd'     => 'fragment-stdd|d=i',
		'sequencing-error'  => 'sequencing-error|e=f',
		'sequencing-type'   => 'sequencing-type|t=s',
		'quality-profile'   => 'quality-profile|q=s',
		'strand-bias'       => 'strand-bias|b=s',
		'seqid-weight'      => 'seqid-weight|w=s',
		'number-of-reads'   => 'number-of-reads|n=i',
		'expression-matrix' => 'expression-matrix|f=s'
	);

	for my $opt (@rm_opt) {
		delete $all_opt{$opt} if exists $all_opt{$opt};
	}

	return super, values %all_opt;
};

sub _log_msg_opt {
	my ($self, $opts) = @_;
	while (my ($key, $value) = each %$opts) {
		next if ref($value) =~ /Fastq/;
		next if not defined $value;
		$key =~ s/_/ /g;
		log_msg "  => $key $value";
	}
}

sub _quality_profile_report {
	my $quality = App::SimulateReads::DB::Handle::Quality->new;
	return $quality->make_report;
}

sub _expression_matrix_report {
	my $expression = App::SimulateReads::DB::Handle::Expression->new;
	return $expression->make_report;
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
	my %default_opt = $self->default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Possible alternatives
	my %STRAND_BIAS       = map { $_ => 1 } @{ &STRAND_BIAS_OPT     };
	my %SEQID_WEIGHT      = map { $_ => 1 } @{ &SEQID_WEIGHT_OPT    };
	my %SEQUENCING_TYPE   = map { $_ => 1 } @{ &SEQUENCING_TYPE_OPT };
	my %COUNT_LOOPS_BY    = map { $_ => 1 } @{ &COUNT_LOOPS_BY_OPT  };
	my %QUALITY_PROFILE   = %{ $self->_quality_profile_report };
	my %EXPRESSION_MATRIX = %{ $self->_expression_matrix_report };

	#  prefix
	if ($opts->{prefix} =~ /([\/\\])/) {
		die "Invalid character in 'prefix' option: $opts->{prefix} => '$1'\n";
	}

	# jobs > 0
	if ($opts->{jobs} <= 0) {
		die "Option 'jobs' requires an integer greater than zero, not $opts->{jobs}\n";
	}

	# 0 <= sequencing_error <= 1
	if (0 > $opts->{'sequencing-error'} || $opts->{'sequencing-error'} > 1)  {
		die "Option 'sequencing-error' requires a value between zero and one, not $opts->{'sequencing-error'}\n";
	}

	# quality_profile
	if ((not exists $QUALITY_PROFILE{$opts->{'quality-profile'}}) && ($opts->{'quality-profile'} ne 'poisson')) {
		my $opt = join ', ' => keys %QUALITY_PROFILE;
		die "Option 'quality-profile' requires one of these arguments: $opt and poisson. Not $opts->{'quality-profile'}\n";
	}

	# 0 < read-size <= 101
	if (0 > $opts->{'read-size'}) {
		die "Option 'read-size' requires an integer greater than zero, not $opts->{'read-size'}\n";
	}

	# read-size if quality-profile is not poisson, test for available sizes
	# TODO: I will be change
	my $quality_entry = $QUALITY_PROFILE{$opts->{'quality-profile'}};
	my %sizes = map { $_->{size} => 1 } @$quality_entry;
	if ((not $sizes{$opts->{'read-size'}}) && ($opts->{'quality-profile'} ne 'poisson')) {
		my $opt = join ', ' => keys %sizes;
		die "Option 'read-size' requires one of these arguments for $opts->{'quality-profile'}: $opt. Not $opts->{'read-size'}\n";
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

		# (fragment_mean - fragment_stdd) >= read_size
		if (($opts->{'fragment-mean'} - $opts->{'fragment-stdd'}) < $opts->{'read-size'}) {
			die "Option 'fragment-mean' minus 'fragment-stdd' requires a value greater or equal read-size, not " .
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

	if (defined $opts->{'number-of-reads'}) {
		if ($opts->{'number-of-reads'} <= 0) {
			die "Option 'number-of-reads' requires a value greater than zero, not $opts->{'number-of-reads'}\n";
		}

		# sequencing_type eq paired-end requires at least 2 reads
		if ($opts->{'number-of-reads'} < 2 && $opts->{'sequencing-type'} eq 'paired-end') {
			die "Option 'number-of-reads' requires a value greater or equal to 2 for paired-end reads, not $opts->{'number-of-reads'}\n";
		}
	}

	# seqid-weight (SEQID_WEIGHT_OPT)
	if (not exists $SEQID_WEIGHT{$opts->{'seqid-weight'}}) {
		my $opt = join ', ' => keys %SEQID_WEIGHT;
		die "Option 'seqid-weight' requires one of these arguments: $opt not $opts->{'seqid_weight'}\n";
	}

	# seqid-weight eq 'count' requires an expression-matrix
	if ($opts->{'seqid-weight'} eq 'count') {
		if (not defined $opts->{'expression-matrix'}) {
			die "Option 'expression-matrix' requires a database entry\n";
		}

		# It is defined, but the entry exists?
		if (not exists $EXPRESSION_MATRIX{$opts->{'expression-matrix'}}) {
			my $opt = join ', ' => keys %EXPRESSION_MATRIX;
			die "Option 'expression-matrix' requires one of these arguments: $opt. Not $opts->{'expression-matrix'}\n";
		}
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $fasta_file = shift @$args;

	my %default_opt = $self->default_opt;
	$self->fill_opts($opts, \%default_opt);

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

	# Sequence identifier
	$opts->{'id'} ||= $opts->{'sequencing-type'} eq 'paired-end' ?
		$opts->{'paired-end-id'} :
		$opts->{'single-end-id'};

	$opts->{id} .= " $opts->{'append-id'}" if defined $opts->{'append-id'};

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
$progname
Date $time_stamp
--------------------------------------------------------
:: Arguments passed by the user:
  => '@$argv'
HEADER

	#-------------------------------------------------------------------------------
	#  Construct the Fastq and Simulator classes
	#-------------------------------------------------------------------------------
	my %paired_end_param = (
		template_id       => $opts->{'id'},
		quality_profile   => $opts->{'quality-profile'},
		sequencing_error  => $opts->{'sequencing-error'},
		read_size         => $opts->{'read-size'},
		fragment_mean     => $opts->{'fragment-mean'},
		fragment_stdd     => $opts->{'fragment-stdd'}
	);

	my %single_end_param = (
		template_id       => $opts->{'id'},
		quality_profile   => $opts->{'quality-profile'},
		sequencing_error  => $opts->{'sequencing-error'},
		read_size         => $opts->{'read-size'}
	);

	my $fastq;
	if ($opts->{'sequencing-type'} eq 'paired-end') {
		log_msg ":: Creating paired-end fastq generator ...";
		$self->_log_msg_opt(\%paired_end_param);
		$fastq = App::SimulateReads::Fastq::PairedEnd->new(%paired_end_param);
	} else {
		log_msg ":: Creating single-end fastq generator ...";
		$self->_log_msg_opt(\%single_end_param);
		$fastq = App::SimulateReads::Fastq::SingleEnd->new(%single_end_param);
	}

	my %simulator_param = (
		fastq             => $fastq,
		fasta_file        => $fasta_file,
		prefix            => $opts->{'prefix'},
		output_gzip       => $opts->{'gzip'},
		seed              => $opts->{'seed'},
		count_loops_by    => $opts->{'count-loops-by'},
		number_of_reads   => $opts->{'number-of-reads'},
		coverage          => $opts->{'coverage'},
		jobs              => $opts->{'jobs'},
		strand_bias       => $opts->{'strand-bias'},
		seqid_weight      => $opts->{'seqid-weight'},
		expression_matrix => $opts->{'expression-matrix'}
	);

	my $simulator;
	log_msg ":: Creating simulator ...";
	$self->_log_msg_opt(\%simulator_param);
	$simulator = App::SimulateReads::Simulator->new(%simulator_param);

	#-------------------------------------------------------------------------------
	#  Let's simulate it!
	#-------------------------------------------------------------------------------
	log_msg ":: Running simulation ...";
	$simulator->run_simulation;

	log_msg ":: End simulation. So long, and thanks for all the fish!";
}
