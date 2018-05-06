package TestsFor::App::Sandy::Fastq::PairedEnd;
# ABSTRACT: Tests for 'App::Sandy::Fastq::PairedEnd' class

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
		fragment_mean    => 50,
		fragment_stdd    => 10,
		template_id      => 'sr0001 simulation_read length=%r position=%c:%t-%n'
	);

	$test->SUPER::setup(%default_attr);
}

sub cleanup : Tests(shutdown) {
	my $test = shift;
	$test->SUPER::shutdown;
}

sub constructor : Tests(12) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $fastq, $attr;
		is $fastq->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub sprint_fastq : Tests(6) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	my $id = "SR0001";
	my $seq_name = "Chr1";
	my ($read1_ref, $read2_ref) = $fastq->sprint_fastq($id, 1, $seq_name, \$seq, length $seq, 1);
	my $read_size = $fastq->read_size;
	my $header = qr/simulation_read length=$read_size position=${seq_name}:\d+-\d+/;
	my $rg = qr/\@.+${header}\n.+\n\+\n.+/;

	for ($read1_ref, $read2_ref) {
		ok $$_ =~ $rg,
			"read retuned by 'fastq' must be in fastq format";
	}
	
	# Testing leader strand paired-end fastq
	my @lines1 = split /\n/ => $$read1_ref;
	my $read_seq1_l1 = substr $lines1[1], 0, $fastq->read_size - 1;
	my $index_s1 = index $seq, $read_seq1_l1;
	my $pos_s1 = $lines1[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos_s1_t = "$seq_name:" . (1 + $index_s1) . "-" . ($fastq->read_size + $index_s1);

	is $pos_s1, $pos_s1_t,
		"The seq_name:start-end inside read 1 fastq header should be the correct relative position";

	my @lines2 = split /\n/ => $$read2_ref;
	$fastq->_read->reverse_complement(\$lines2[1]);
	my $read_seq2_f1 = substr $lines2[1], 1, $fastq->read_size;
	my $index_s2 = index $seq, $read_seq2_f1;
	my $pos_s2 = $lines2[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos_s2_t = "$seq_name:" . ($fastq->read_size + $index_s2 - 1) . "-" . ($index_s2);

	is $pos_s2, $pos_s2_t,
		"The seq_name:end-start inside read 2 fastq header should be the correct relative position";
	
	# Testing retarded strand paired-end fastq
	my ($read2_1_ref, $read2_2_ref) = $fastq->sprint_fastq($id, 1, $seq_name, \$seq, length $seq, 0);

	my @lines3 = split /\n/ => $$read2_1_ref;
	$fastq->_read->reverse_complement(\$lines3[1]);
	my $read2_seq1_f1 = substr $lines3[1], 1, $fastq->read_size;
	my $index2_s1 = index $seq, $read2_seq1_f1;
	my $pos2_s1 = $lines3[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos2_s1_t = "$seq_name:" . ($fastq->read_size + $index2_s1 - 1) . "-" . ($index2_s1);

	is $pos2_s1, $pos2_s1_t,
		"The seq_name:end-start inside read 1 fastq header (retarded strand) should be the correct relative position";

	my @lines4 = split /\n/ => $$read2_2_ref;
	my $read2_seq2_l1 = substr $lines4[1], 0, $fastq->read_size - 1;
	my $index2_s2 = index $seq, $read2_seq2_l1;
	my $pos2_s2 = $lines4[0] =~ /position=(.+)/ ? $1 : undef;
	my $pos2_s2_t = "$seq_name:" . ($index2_s2 + 1) . "-" . ($fastq->read_size + $index2_s2);

	is $pos2_s2, $pos2_s2_t,
		"The seq_name:start-end inside read 2 fastq header (retarded strand) should be the correct relative position";
}

## --- end class TestsFor::Fastq::PairedEnd
