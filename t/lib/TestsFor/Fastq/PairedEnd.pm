#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Tests for 'Fastq::PairedEnd' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 14-05-2017 18:30:15
#     REVISION: ---
#===============================================================================

package TestsFor::Fastq::PairedEnd;

use Test::Most;
use autodie;
use base 'TestsFor::Fastq';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;

	my %default_attr = (
		sequencing_error => 0.1,
		fragment_mean    => 50,
		fragment_stdd    => 10
	);

	$test->SUPER::setup(%default_attr);
}

sub cleanup : Tests(shutdown) {
	my $test = shift;
	$test->SUPER::shutdown;
}

sub constructor : Tests(10) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $fastq, $attr;
		is $fastq->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub fastq : Tests(5) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	my $id = "SR0001";
	my $seq_name = "Chr1";
	my $read = $fastq->fastq($id, $seq_name, \$seq, length $seq, 1);
	my $header = "Simulation_read sequence_position=$seq_name";
	my $rg = qr/\@${id} [12] ${header}:\d+-\d+\n.+\n\+${id} [12] ${header}:\d+-\d+\n.+\n\@${id} [12] ${header}:\d+-\d+\n.+\n\+${id} [12] ${header}:\d+-\d+\n.+/;
	ok $read =~ $rg,
		"read retuned by 'fastq' must be in fastq format";
	
	# Testing leader strand paired-end fastq
	my @lines = split /\n/ => $read;
	my $read_seq1_l1 = substr $lines[1], 0, $fastq->read_size - 1;
	my $index_s1 = index $seq, $read_seq1_l1;
	my $pos_s1 = $lines[0] =~ /sequence_position=(.+)/ ? $1 : undef;
	my $pos_s1_t = "$seq_name:" . (1 + $index_s1) . "-" . ($fastq->read_size + $index_s1);

	is $pos_s1, $pos_s1_t,
		"The seq_name:start-end inside read 1 fastq header should be the correct relative position";

	$fastq->_read->reverse_complement(\$lines[5]);
	my $read_seq2_f1 = substr $lines[5], 1, $fastq->read_size;
	my $index_s2 = index $seq, $read_seq2_f1;
	my $pos_s2 = $lines[4] =~ /sequence_position=(.+)/ ? $1 : undef;
	my $pos_s2_t = "$seq_name:" . ($fastq->read_size + $index_s2 - 1) . "-" . ($index_s2);

	is $pos_s2, $pos_s2_t,
		"The seq_name:end-start inside read 2 fastq header should be the correct relative position";
	
	# Testing retarded strand paired-end fastq
	my $read2 = $fastq->fastq($id, $seq_name, \$seq, length $seq, 0);

	my @lines2 = split /\n/ => $read2;
	$fastq->_read->reverse_complement(\$lines2[1]);
	my $read2_seq1_f1 = substr $lines2[1], 1, $fastq->read_size;
	my $index2_s1 = index $seq, $read2_seq1_f1;
	my $pos2_s1 = $lines2[0] =~ /sequence_position=(.+)/ ? $1 : undef;
	my $pos2_s1_t = "$seq_name:" . ($fastq->read_size + $index2_s1 - 1) . "-" . ($index2_s1);

	is $pos2_s1, $pos2_s1_t,
		"The seq_name:end-start inside read 1 fastq header (retarded strand) should be the correct relative position";

	my $read2_seq2_l1 = substr $lines2[5], 0, $fastq->read_size - 1;
	my $index2_s2 = index $seq, $read2_seq2_l1;
	my $pos2_s2 = $lines2[4] =~ /sequence_position=(.+)/ ? $1 : undef;
	my $pos2_s2_t = "$seq_name:" . ($index2_s2 + 1) . "-" . ($fastq->read_size + $index2_s2);

	is $pos2_s2, $pos2_s2_t,
		"The seq_name:start-end inside read 2 fastq header (retarded strand) should be the correct relative position";
}

1;
