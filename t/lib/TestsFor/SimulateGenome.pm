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
	COVERAGE      => 5,
	PREFIX        => 'ponga'
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

sub run_simulation : Tests() {
	my $test = shift;

#	my $sg_single_end = $test->default_sg_single_end;
#	$sg_single_end->run_simulation;
	
	my $sg_paired_end = $test->default_sg_paired_end;
	$sg_paired_end->run_simulation;
}

1;
