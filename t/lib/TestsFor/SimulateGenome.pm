#
#===============================================================================
#
#         FILE: SimulateGenome.pm
#
#  DESCRIPTION: Tests for 'SimulateGenome' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 20-05-2017 20:55:12
#     REVISION: ---
#===============================================================================

package TestsFor::SimulateGenome;

use Test::Most;
use Fastq::SingleEnd;
use Fastq::PairedEnd;
use autodie;
use base 'TestsFor';
 
use constant {
	QUALITY       => '.data.txt',
	QUALITY_SIZE  => 10,
	QUALITY_LINES => 25,
	GENOME        => '.data.fa',
	GENOME_SIZE   => 1981,
	COVERAGE      => 5,
	PREFIX        => 'ponga',
	OUTPUT        => 'ponga_simulation_seq.fastq'
};

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_attr');
	$class->mk_classdata('default_sg_single_end');
	$class->mk_classdata('default_sg_paired_end');

	my $quality = q{*++++,,--.
,)+-0,*,/~
,)+-0,*,/~
,)+-0,*,/~
,)+-0,*,/~
,)+-0,*,/~
,)+*0,*,/~
,)+*0,*,/~
,)+*0,*,/~
*(+*0,*11~
*(+*),+11~
*(+*),+11~
*(+*),+11~
*(+*),+11~
*(+*)/011~
*(-*)/011~
*(-*)/011~
*(-.)/011~
*(-.)/011~
*(-.)/011~
*(-.)/011/
*(-.)-011/
*(-.)-011/
*+-.)-011/
*+-.)-011/};

	my $genome = q{>Chr1
TTACTGCTTTTAACATTACAGTAACTGTTACAGGTTCCAGCAGGCTAACTGGGTGGAAAT
GAGTTTGGTTTCACTTAGTCTCTCTAAAGAGAAAGCAAGTCGGTAGACTAATACCTAATA
AAAGCAAAGCTGCCAACAATTGAAATTGCCTAGGCTGCTCTGTGTGTCCCACATGCATGG
GTGTGGGTGCCAGTGTGTGTGCGTGTGTGCATGCATGTGCATGTGTGTTGGGATAGAGTG
GTAAGAAAATGGGAAATAATAAGAATGTTCAGTCCATAGCCCTTCATTATAAAAAGGTGA
GCTGTAATAAATACTAGTGCCACATTTAGCCAAAACTTTACTCCAGCCAAAGGTGATATT
TTCATGATAACATCCTGTGATTGCTTTGTTCTTCGTCTTTTATGTTCTTCCTAGATGGGC
TCAGAACATACAAGAATTAAGTACACATCTTATTTTCCAGTGATAATGCTACCGGCAAAT
TCTGTTGTTTGTATAAACATCAGCCATGTTTATATAACTAAACTAGTGTTTTGTTTTGTC
>Chr2
AATTCAGCAAGAAATTAGACCAAATGGTGGCTTAATGCTGCATTGATTTGGCTATCAATT
TGTTTTCACTTTTCTGCAAAATAATTAATACATTATTAAATTGAATTGTGCTGATGCCAC
>Chr3
AGTTGTTCTTATCTCAAGTGTCTTAAAATTCATTTAATTTGTTTTTCCTTTGGTTTCATT
ATTCAAATTTTAACTTCAGTTCTCAAGATTTTATCTGATGGAAGAGATGGAGTCCATTAC
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

	open my $fh, ">" => QUALITY;
	print $fh "$quality\n";
	close $fh;

	open $fh, ">" => GENOME;
	print $fh "$genome\n";
	close $fh;
}

sub setup : Tests(setup) {
	my $test = shift;
	$test->SUPER::setup;

	my %default_attr = (
		prefix         => PREFIX,
		output_gzipped => 0,
		genome_file    => GENOME,
		coverage       => COVERAGE
	);
	
	my %sg_single_end = (
		%default_attr,
		fastq => Fastq::SingleEnd->new(
			quality_file     => QUALITY,
			read_size        => QUALITY_SIZE,
			sequencing_error => 0.1,
		)
	);

	my %sg_paired_end = (
		%default_attr,
		fastq => 	Fastq::PairedEnd->new(
			quality_file     => QUALITY,
			read_size        => QUALITY_SIZE,
			sequencing_error => 0.1,
			fragment_mean    => 50,
			fragment_stdd    => 10
		)
	);

	$test->default_attr(\%default_attr);
	$test->default_sg_single_end($test->class_to_test->new(%sg_single_end));
	$test->default_sg_paired_end($test->class_to_test->new(%sg_paired_end));
}

sub cleanup : Tests(shutdown) {
	my $test = shift;
	unlink QUALITY;
	unlink GENOME;
	$test->SUPER::shutdown;
}

sub constructor : Tests(8) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $sg = $test->default_sg_single_end;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $sg, $attr;
		is $sg->$attr, $value, "The value for $attr shold be correct";
	}
}

sub run_simulation : Tests(6) {
	my $test = shift;
	my $output = OUTPUT;

	for my $fun (qw/default_sg_single_end default_sg_paired_end/) {
		my $sg = $test->$fun;
		$sg->run_simulation;

		ok -f OUTPUT,
			"run_simulation must create a fastq file for $fun";
		
		my $entries = 0;
		my %chr_acm;
		open my $fh, "<" => $output;
		while (<$fh>) {
			chomp;
			if (/^@/) {
				$entries++;
				my @tmp1 = split / /;
				my @tmp2 = split /=/ => $fun =~ /paired_end/ ? $tmp1[3] : $tmp1[2];
				my @tmp3 = split /:/ => $tmp2[1];
				$chr_acm{$tmp3[0]}++;
			}
		}
		close $fh;

		$entries = $entries / 2 if $fun =~ /paired_end/;

		is int((GENOME_SIZE * $sg->coverage)/$sg->fastq->read_size), $entries,
			"run_simulation must create a fastq with the right number of entries for $fun";

		my $str_sort = join " " => sort { $chr_acm{$a} <=> $chr_acm{$b} } keys %chr_acm;
		ok(($str_sort eq "Chr2 Chr3 Chr5 Chr1 Chr4" || $str_sort eq "Chr3 Chr2 Chr5 Chr1 Chr4"),
			"chromossome frequency must follow a weighted raffle pattern for $fun");
			
		unlink OUTPUT;
	}
}

1;
