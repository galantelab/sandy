package App::SimulateReads::Role::Digest;
# ABSTRACT: Wrapper on Simulator class for genome/transcriptome sequencing

use App::SimulateReads::Base 'role';
use App::SimulateReads::Quality::Handle;
use App::SimulateReads::Fastq::SingleEnd;
use App::SimulateReads::Fastq::PairedEnd;
use App::SimulateReads::Simulator;
use Path::Class 'file';
use File::Path 'make_path';

requires qw/default_opt opt_spec/;

# VERSION

use constant {
	COUNT_LOOPS_BY_OPT    => ['coverage', 'number-of-reads'],
	STRAND_BIAS_OPT       => ['random', 'plus', 'minus'],
	SEQID_WEIGHT_OPT      => ['length', 'same', 'file'],
	SEQUENCING_TYPE_OPT   => ['single-end', 'paired-end']
};

override 'opt_spec' => sub {
	super,
	'prefix|p=s',
	'verbose|v',
	'output-dir|o=s',
	'jobs|j=i',
	'gzip|z!',
	'coverage|c=f',
	'read-size|r=i',
	'fragment-mean|m=i',
	'fragment-stdd|d=i',
	'sequencing-error|e=f',
	'sequencing-type|t=s',
	'quality-profile|q=s',
	'strand-bias|b=s',
	'seqid-weight|w=s',
	'number-of-reads|n=i',
	'weight-file|f=s'
};

sub _log_msg_opt {
	my ($self, $opts) = @_;
	while (my ($key, $value) = each %$opts) {
		next if ref($value) =~ /Fastq/;
		$value = "not defined" if not defined $value;
		$key =~ s/_/ /g;
		log_msg "  => $key $value";
	}
}

sub _quality_profile_report {
	my $quality = App::SimulateReads::Quality::Handle->new;
	return $quality->make_report;
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
	my %QUALITY_PROFILE   = %{ $self->_quality_profile_report };

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

	# count-loops-by (COUNT_LOOPS_BY_OPT). The default value is counting by coverage
	# Or calculate number of reads by coverage, or the user pass the number-of-reads.
	# number-of-reads option overrides coverage
	if (exists $opts->{'number-of-reads'}) {
		# number_of_reads > 0
		if ($opts->{'number-of-reads'} <= 0) {
			die "Option 'number-of-reads' requires a value greater than zero, not $opts->{'number-of-reads'}\n";
		}

		# sequencing_type eq paired-end requires at least 2 reads
		if ($opts->{'number-of-reads'} < 2 && $opts->{'sequencing-type'} eq 'paired-end') {
			die "Option 'number-of-reads' requires a value greater or equal to 2 for paired-end reads, not $opts->{'number-of-reads'}\n";
		}
	}

	# coverage > 0
	if ($opts->{coverage} <= 0) {
		die "Option 'coverage' requires a value greater than zero, not $opts->{coverage}\n";
	}

	# seqid-weight (SEQID_WEIGHT_OPT)
	if (not exists $SEQID_WEIGHT{$opts->{'seqid-weight'}}) {
		my $opt = join ', ' => keys %SEQID_WEIGHT;
		die "Option 'seqid-weight' requires one of these arguments: $opt not $opts->{'seqid_weight'}\n";
	}

	# seqid-weight eq 'file' requires a weight-file
	if ($opts->{'seqid-weight'} eq 'file') {
		if (not defined $opts->{'weight-file'}) {
			die "Option 'seqid-weight=file' requires the argument 'weight-file' with a tab-separated values file\n";
		}

		# It is defined, but the file exists?
		if (not -f $opts->{'weight-file'}) {
			die "Option 'weight-file' requires a valid file, not $opts->{'weight-file'}\n";
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

	# Set default count-loop-by behavior
	# TODO: Set number-of-reads or coverage depending of count-loop-by:
	# That means: If it is genome number-of-reads override coverage and for transcriptome
	# coverage override number-of-reads
	$opts->{'count-loops-by'} = 'number-of-reads' if exists $opts->{'number-of-reads'};

	# Create output directory if it not exist
	make_path($opts->{'output-dir'}, {error => \my $err_list});
	my $err_dir;
	if (@$err_list) {
		for (@$err_list) {
			my ($dir, $message) = %$_;
			$err_dir .= "Problem creating '$dir': $message\n";
		}
		die "$err_dir";
	}

	# Concatenate output-dir to prefix
	my $prefix = file($opts->{'output-dir'}, $opts->{prefix});
	$opts->{prefix} = "$prefix";

	#-------------------------------------------------------------------------------
	#  Log presentation header
	#-------------------------------------------------------------------------------
	my $time_stamp = localtime;
	my $progname   = $self->progname;
	my $argv = $self->argv;
log_msg <<"HEADER";
--------------------------------------------------------
 Date $time_stamp
 $progname Copyright (C) 2017 Thiago L. A. Miller
--------------------------------------------------------
:: Arguments passed by the user:
  => '@$argv'
HEADER

	#-------------------------------------------------------------------------------
	#  Construct the Fastq and Simulator classes
	#-------------------------------------------------------------------------------
	my %paired_end_param = (
		quality_profile   => $opts->{'quality-profile'},
		sequencing_error  => $opts->{'sequencing-error'},
		read_size         => $opts->{'read-size'},
		fragment_mean     => $opts->{'fragment-mean'},
		fragment_stdd     => $opts->{'fragment-stdd'}
	);

	my %single_end_param = (
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
		count_loops_by    => $opts->{'count-loops-by'},
		number_of_reads   => $opts->{'number-of-reads'},
		coverage          => $opts->{'coverage'},
		jobs              => $opts->{'jobs'},
		strand_bias       => $opts->{'strand-bias'},
		seqid_weight      => $opts->{'seqid-weight'},
		weight_file       => $opts->{'weight-file'}
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
