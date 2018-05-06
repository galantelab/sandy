package TestsFor::App::Sandy::Fastq::SingleEnd;
# ABSTRACT: Tests for 'App::Sandy::Fastq::SingleEnd' class

use App::Sandy::Base 'test';
use base 'TestsFor::App::Sandy::Fastq';
use autodie;

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;

	my %default_attr = (
		sequencing_error => 0.1,
		template_id      => 'sr0001 simulation_read length=%r position=%c:%t-%n'
	);

	$test->SUPER::setup(%default_attr);
}

sub cleanup : Tests(shutdown) {
	my $test = shift;
	$test->SUPER::shutdown;
}

sub constructor : Tests(8) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $fastq, $attr;
		is $fastq->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub sprint_fastq : Tests(3) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	my $id = "sr0001";
	my $seq_name = "Chr1";
	my $read_ref = $fastq->sprint_fastq($id, 1, $seq_name, \$seq, length $seq, 1);
	my $read_size = $fastq->read_size;

	my $header = qr/simulation_read length=$read_size position=${seq_name}:\d+-\d+/;
	my $rg = qr/\@.+${header}\n.+\n\+\n.+/;
	ok $$read_ref =~ $rg,
		"read retuned by 'fastq' must be in fastq format";
	
	my @lines = split /\n/ => $$read_ref;
	my $read_seq_l1 = substr $lines[1], 0, $fastq->read_size - 1;
	my $index = index $seq, $read_seq_l1;
	my $pos = $lines[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos_t = "$seq_name:" . (1 + $index) . "-" . ($fastq->read_size + $index);

	is $pos, $pos_t,
		"The seq_name:start-end inside fastq header should be the correct relative position";

	my $read2_ref = $fastq->sprint_fastq($id, 1, $seq_name, \$seq, length $seq, 0);

	my @lines2 = split /\n/ => $$read2_ref;
	$fastq->_read->reverse_complement(\$lines2[1]);
	my $read2_seq_f1 = substr $lines2[1], 1, $fastq->read_size;
	my $index2 = index $seq, $read2_seq_f1;
	my $pos2 = $lines2[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos2_t = "$seq_name:" . ($fastq->read_size + $index2 - 1) . "-" . ($index2);

	is $pos2, $pos2_t,
		"The seq_name:end-start inside fastq header should be the correct relative position";
}

## --- end class TestsFor::Fastq::SingleEnd;
