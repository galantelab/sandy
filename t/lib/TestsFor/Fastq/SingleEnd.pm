#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: Tests for 'Fastq::SingleEnd' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 14-05-2017 01:34:50
#     REVISION: ---
#===============================================================================

package TestsFor::Fastq::SingleEnd;

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
		sequencing_error => 0.1
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

sub fastq : Tests(3) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	my $id = "SR0001";
	my $seq_name = "Chr1";
	my $read = $fastq->fastq($id, $seq_name, \$seq, length $seq, 1);
	my $read_size = $fastq->read_size;

	my $header = qr/$id\|${seq_name}:\d+-\d+ simulation_read length=$read_size/;
	my $rg = qr/\@${header}\n.+\n\+\n.+/;
	ok $read =~ $rg,
		"read retuned by 'fastq' must be in fastq format";
	
	my @lines = split /\n/ => $read;
	my $read_seq_l1 = substr $lines[1], 0, $fastq->read_size - 1;
	my $index = index $seq, $read_seq_l1;
	my $pos = $lines[0] =~ /\|(.+?) / ? $1 : undef;
	my $pos_t = "$seq_name:" . (1 + $index) . "-" . ($fastq->read_size + $index);

	is $pos, $pos_t,
		"The seq_name:start-end inside fastq header should be the correct relative position";

	my $read2 = $fastq->fastq($id, $seq_name, \$seq, length $seq, 0);

	my @lines2 = split /\n/ => $read2;
	$fastq->_read->reverse_complement(\$lines2[1]);
	my $read2_seq_f1 = substr $lines2[1], 1, $fastq->read_size;
	my $index2 = index $seq, $read2_seq_f1;
	my $pos2 = $lines2[0] =~ /\|(.+?) / ? $1 : undef;
	my $pos2_t = "$seq_name:" . ($fastq->read_size + $index2 - 1) . "-" . ($index2);

	is $pos2, $pos2_t,
		"The seq_name:end-start inside fastq header should be the correct relative position";
}

1;
