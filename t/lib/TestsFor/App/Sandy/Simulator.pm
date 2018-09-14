package TestsFor::App::Sandy::Simulator;
# ABSTRACT: Tests for 'App::Sandy::Simulator' class

use App::Sandy::Base 'test';
use App::Sandy::Seq::SingleEnd;
use App::Sandy::Seq::PairedEnd;
use autodie;

use base 'TestsFor';

use constant {
	VERBOSE           => 0,
	LEVEL             => 6,
	COUNT_LOOPS_BY    => 'coverage',
	COVERAGE          => 8,
	STRAND_BIAS       => 'random',
	SEQID_WEIGHT      => 'length',
	SEQUENCING_TYPE   => 'paired-end',
	SEQUENCING_SYSTEM => 'poisson',
	SEED              => time,
	JOBS              => 2,
	FORMAT            => 'fastq',
	SEQ_SYS           => 'poisson',
	QUALITY_SIZE      => 10,
	GENOME            => '.data.fa',
	GENOME_SIZE       => 2280,
	COVERAGE          => 5,
	PREFIX            => 'ponga',
	OUTPUT_SINGLE_END => 'ponga_R1_001.fastq',
	OUTPUT_PAIRED_END => ['ponga_R1_001.fastq', 'ponga_R2_001.fastq'],
	OUTPUT_COUNTS     => 'ponga_coverage.tsv'
};

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_attr');
	$class->mk_classdata('default_sg_single_end');
	$class->mk_classdata('default_sg_paired_end');

	my $fasta = q{>Chr1
TTACTGCTTTTAACATTACAGTAACTGTTACAGGTTCCAGCAGGCTAACTGGGTGGAAAT
GAGTTTGGTTTCACTTAGTCTCTCTAAAGAGAAAGCAAGTCGGTAGACTAATACCTAATA
AAAGCAAAGCTGCCAACAATTGAAATTGCCTAGGCTGCTCTGTGTGTCCCACATGCATGG
GTGTGGGTGCCAGTGTGTGTGCGTGTGTGCATGCATGTGCATGTGTGTTGGGATAGAGTG
GTAAGAAAATGGGAAATAATAAGAATGTTCAGTCCATAGCCCTTCATTATAAAAAGGTGA
GCTGTAATAAATACTAGTGCCACATTTAGCCAAAACTTTACTCCAGCCAAAGGTGATATT
TTCATGATAACATCCTGTGATTGCTTTGTTCTTCGTCTTTTATGTTCTTCCTAGATGGGC
TCAGAACATACAAGAATTAAGTACACATCTTATTTTCCAGTGATAATGCTACCGGCAAAT
TCTGTTGTTTGTATAAACATCAGCCATGTTTATATAACTAAACTAGTGTTTTGTTTTGTC
TCCCAATCTCCTACCATCCCATCCTAATATGACAGAAGTAATTCCTGAGTTGCTTCTGAA
>Chr2
AATTCAGCAAGAAATTAGACCAAATGGTGGCTTAATGCTGCATTGATTTGGCTATCAATT
TGTTTTCACTTTTCTGCAAAATAATTAATACATTATTAAATTGAATTGTGCTGATGCCAC
>Chr3
AGTTGTTCTTATCTCAAGTGTCTTAAAATTCATTTAATTTGTTTTTCCTTTGGTTTCATT
ATTCAAATTTTAACTTCAGTTCTCAAGATTTTATCTGATGGAAGAGATGGAGTCCATTAC
TGTTTTCACTTTTCTGCAAAATAATTAATACATTATTAAATTGAATTGTGCTGATGCCAC
AGTTGTTCTTATCTCAAGTGTCTTAAAATTCATTTAATTTGTTTTTCCTTTGGTTTCATT
>Chr4
TAAGGACTCCATTGTGCTCCATCATGCCAGAGTTGTAAAATAGATCTTTTAAAGGAAATT
TACTGTGATTTTTTTTCTATTTAAGAGCTTCCTCTCCAGTTGAGCATGTAAGAAAATTAT
ACCAGGAGAATACAGTAAACTCTATGAGGCAAGCTATAAACATGTAGCATTGTGATTAGG
GCTGGTTCTCCTTCTAGAGACATGGTAGGATTGCAATTTCATACCATCCTTGAAGTTAGA
GAGAGCCACGTGACTCATTTAGCCAATGAACTGTGAGCAGAATGACATGTCACTTCCAGC
TGAAGCTTTAACAATCTGAGAGACATTCATACATTTTCCATGTGCTGTAGCCTTATACCC
AAAGCCTGGGTCCCAAGTGACCATGACAGGCAGAGCTCCCTGTTGAGCCACAGAGATTTA
GAGAATGGCTGTTAACACAGCATAATCCAGCCCATCCTGACTAATCTGATATTAACATGT
ATAATAAAGAATTCTATCAATGCTGAGGGAAGATGACTAGTTAAGGTCCTAGGTTGCAAG
TCTCAAAACCTCTTCTAAGGATTGTAGACAGGAAATTAAATGACTTCTAGTCCCTAGAGT
TCCCAATCTCCTACCATCCCATCCTAATATGACAGAAGTAATTCCTGAGTTGCTTCTGAA
TCCCAATCTCCTACCATCCCATCCTAATATGACAGAAGTAATTCCTGAGTTGCTTCTGAA
TCCCAATCTCCTACCATCCCATCCTAATATGACAGAAGTAATTCCTGAGTTGCTTCTGAA
ACCAGAGCTTCCCTCAGAACCCTTAGCCTGCCAGATGGCTTCTTGGAGAGCCCTCACTCA
CTTTTCTCCTTCTGCTATTGCTGCTCATTCATTCCAGTTTTTAAAAATTCATCTTTATCC
>Chr5
AGGAACCTCGCTTCTAGAAAAGTCATACAGGTGCTTCCAGGAGGCTACATGGGCACCCAT
ATTTTTCTAGCCACTTTCATTAGACCAATGCAGCAGAGAAGAAAAGCCTCAATAATTATT
ATGACATGGCATGTTAGGATACCAAGTAAATTGCATTTGTAAAATGTGATTTTCTGTTGG
TGTTCACTTCAGCTCTACTGACATTTGGTAAGTATTATTGACTGACTGACTAACTAATGT
GGTCATTAGTCTTCATAAAGAAAGGCTCTCTACAAAAACGGAGGGATGCCCTTTTTCTGG
CATTTAATACGTAAGAAATTGCCTCCAATAGAAACCAGAGTTGCCTGATTACTATCAGCA
CAGGAGAAATGTATTAATGTGCCTTTCTAGTAACAGGTTTTTAGAAAGTCAAATATAAAC};

	open my $fh, ">" => GENOME;
	print $fh "$fasta\n";
	close $fh;
}

sub setup : Tests(setup) {
	my $test = shift;
	$LOG_VERBOSE = VERBOSE;
	$test->SUPER::setup;

	my %default_attr = (
		argv              => [qw/ponga 1 2 3 4 5/],
		truncate          => 0,
		join_paired_ends  => 0,
		prefix            => PREFIX,
		fasta_file        => GENOME,
		coverage          => COVERAGE,
		jobs              => JOBS,
		output_format     => FORMAT,
		seqid_weight      => 'length',
		count_loops_by    => 'coverage',
		strand_bias       => 'random',
		seed              => SEED,
		compression_level => LEVEL
	);

	my %sg_single_end = (
		%default_attr,
		seq => App::Sandy::Seq::SingleEnd->new(
			quality_profile   => 'poisson',
			read_mean         => QUALITY_SIZE,
			read_stdd         => 0,
			sequencing_error  => 0.1,
			template_id       => 'sr0001 simulation_read length=%r position=%c:%t-%n',
			format            => FORMAT
		)
	);

	my %sg_paired_end = (
		%default_attr,
		seq => App::Sandy::Seq::PairedEnd->new(
			quality_profile   => 'poisson',
			read_mean         => QUALITY_SIZE,
			read_stdd         => 0,
			sequencing_error  => 0.1,
			fragment_mean     => 50,
			fragment_stdd     => 10,
			template_id       => 'sr0001 simulation_read length=%r position=%c:%t-%n',
			format            => FORMAT
		)
	);

	$test->default_attr(\%default_attr);
	$test->default_sg_single_end($test->class_to_test->new(%sg_single_end));
	$test->default_sg_paired_end($test->class_to_test->new(%sg_paired_end));
}

sub cleanup : Tests(shutdown) {
	my $test = shift;
	unlink GENOME;
	$test->SUPER::shutdown;
}

sub constructor : Tests(26) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $sg = $test->default_sg_single_end;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $sg, $attr;
		is $sg->$attr, $value, "The value for $attr shold be correct";
	}
}

sub run_simulation : Tests(9) {
	my $test = shift;
	my $output_single_end = OUTPUT_SINGLE_END;
	my $output_paired_end = OUTPUT_PAIRED_END;
	my $output_counts = OUTPUT_COUNTS;

	my $fastq_count = sub {
		my $file = shift;
		my $entries = 0;
		my %chr_acm;
		open my $fh, "<" => $file;
		my $mark = 4;
		my $acm = 0;
		while (<$fh>) {
			chomp;
			if (++$acm == 1) {
				$entries++;
				my @tmp1 = split / /;
				my @tmp2 = split /:/ => $tmp1[-1];
				my @tmp3 = split /=/ => $tmp2[0];
				$chr_acm{$tmp3[1]}++;
			} elsif ($acm == $mark) {
				$acm = 0;
			}
		}
		close $fh;
		return (\%chr_acm, $entries);
	};

	# Testing single-end
	my $sg = $test->default_sg_single_end;
	$sg->run_simulation;
	ok -f $output_single_end,
		"run_simulation must create a fastq file for single-end";

	my ($chr_acm, $entries) = $fastq_count->($output_single_end);

	is int((GENOME_SIZE * $sg->coverage) / $sg->seq->read_mean), $entries,
		"run_simulation must create a fastq with the right number of entries for single-end";

	my $str_sort = join " " => sort { $chr_acm->{$a} <=> $chr_acm->{$b} } keys %$chr_acm;
	ok((lc $str_sort eq lc "Chr2 Chr3 Chr5 Chr1 Chr4" || lc $str_sort eq lc "Chr3 Chr2 Chr5 Chr1 Chr4"),
		"chromossome frequency must follow a weighted raffle pattern for single-end");

	unlink $output_single_end;

	# Testing paired-end
	$sg = $test->default_sg_paired_end;
	$sg->run_simulation;

	for my $i (0..1) {
		ok -f $output_paired_end->[$i],
			"run_simulation must create fastq file for paired-end $i";

		($chr_acm, $entries) = $fastq_count->($output_paired_end->[$i]);

		is int((GENOME_SIZE * $sg->coverage) / ($sg->seq->read_mean * 2)), $entries,
			"run_simulation must create a fastq with the right number of entries for paired-end $i";

		my $str_sort = join " " => sort { $chr_acm->{$a} <=> $chr_acm->{$b} } keys %$chr_acm;
		ok((lc $str_sort eq lc "Chr2 Chr3 Chr5 Chr1 Chr4" || lc $str_sort eq lc "Chr3 Chr2 Chr5 Chr1 Chr4"),
			"chromossome frequency must follow a weighted raffle pattern ($str_sort) for paired-end $i");

		unlink $output_paired_end->[$i];
	}

	unlink $output_counts;
}
