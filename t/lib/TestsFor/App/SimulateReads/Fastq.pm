package TestsFor::App::SimulateReads::Fastq;
# ABSTRACT: Tests for 'App::SimulateReads::Fastq' class

use App::SimulateReads::Base 'test';
use base 'TestsFor';
use autodie;

use constant {
	SEQ_SYS       => 'poisson',
	QUALITY_SIZE  => 10,
};

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_fastq');
	$class->mk_classdata('default_attr');
	$class->mk_classdata('seq');
	$class->mk_classdata('seq_len');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	my %default_attr = (
		quality_profile => SEQ_SYS,
		read_size       => QUALITY_SIZE,
		%child_arg
	);

	$test->default_attr(\%default_attr);
	$test->default_fastq($test->class_to_test->new(%default_attr));

	my $seq = 'TGACCCGCTAACCTCAGTTCTGCAGCAGTAACAACTGCCGTATCTGGACTTTCCTAATACCTCGCATAGTCCGTCCCCTCGCGCGGCAAGAGGTGCGGCG';
	$test->seq($seq);
	$test->seq_len(length $seq);
}

sub constructor : Tests(4) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $fastq, $attr;
		is $fastq->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub fastq_template : Tests(1) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	
	my $header = "PONGA_HEADER";		
	my $seq = "ATCGATCGAT";
	
	my $quality_size = QUALITY_SIZE;
	my $rg = qr/\@${header}\n${seq}\n\+\n.{$quality_size}/;
	ok ${ $fastq->fastq_template(\$header, \$seq) } =~ $rg,
		"'fastq' should return an entry in fastq format";
}

## --- end class TestsFor::Fastq
