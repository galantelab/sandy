#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Tests for 'Read::PairedEnd' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/09/2017 10:59:55 AM
#     REVISION: ---
#===============================================================================

package TestsFor::Read::PairedEnd;

use Test::Most;
use base 'TestsFor::Read';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;

	my %default_attr = (
		fragment_mean    => 50,
		fragment_stdd    => 10
	);

	$test->SUPER::setup(%default_attr);
}

sub constructor : Tests(11) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $read = $test->default_read;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $read, $attr;
		is $read->$attr, $value,"The value for $attr shold be correct";
	}

	my %attrs = %default_attr;
	
	$attrs{fragment_mean} = 50;
	$attrs{read_size} = 51;
	throws_ok { $class->new(%attrs) }
	qr/must be greater or equal/,
		"Setting fragment_mean to less than read_size should fail";
}

sub gen_read : Tests(122) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	throws_ok { $read->gen_read(\$seq, $read->read_size - 1, 1) }
	qr/The constraints were not met/,
		"Sequence length lesser than read_size must return error";
	
	my $err = 0;
	for (1..100) {
		my ($r1, $r2, $frag_pos, $frag_size) = $read->gen_read(\$seq, $seq_len, 1);
		$err++ unless defined $r1 && defined $r2 && defined $frag_pos && defined $frag_size;
	}

	ok $err == 0, "100 tries: It must not give error";
	
	for my $i (0..9) {
		#For leader strand
		my ($r1, $r2, $frag_pos, $frag_size) = $read->gen_read(\$seq, $seq_len, 1);
		ok index($seq, $r1) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd -> read1). Try $i";
		my $r1_l1 = substr $r1, 0, $read->read_size - 1;
		ok index($seq, $r1_l1) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (PairedEnd -> read1). Try $i";
		is index($seq, $r1_l1), $frag_pos,
			"Position returned must be equal to index in gen_read (PairEnd -> read1). Try $i";

		$read->reverse_complement(\$r2);
		ok index($seq, $r2) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd -> read2). Try $i";
		my $r2_f1 = substr $r2, 1, $read->read_size;
		ok index($seq, $r2_f1) >= 0,
			"Sequence with error (but first char -> err) must be inside seq in gen_read (PairedEnd -> read2). Try $i";
		is index($seq, $r2_f1), $frag_pos + $frag_size - $read->read_size + 1,
			"Position returned + fragment size must be equal to index in gen_read (PairEnd -> read2). Try $i";

		#For retarded strand
		my ($r3, $r4, $frag_pos2, $frag_size2) = $read->gen_read(\$seq, $seq_len, 0);
		ok index($seq, $r4) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd, reverse_complement -> read2). Try $i";
		my $r4_l1 = substr $r4, 0, $read->read_size - 1;
		ok index($seq, $r4_l1) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (PairedEnd, reverse_complement -> read2). Try $i";
		is index($seq, $r4_l1), $frag_pos2,
			"Position returned must be equal to index in gen_read (PairEnd, reverse_complement -> read2). Try $i";

		$read->reverse_complement(\$r3);
		ok index($seq, $r3) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd, reverse_complement -> read1). Try $i";
		my $r3_f1 = substr $r2, 1, $read->read_size;
		ok index($seq, $r3_f1) >= 0,
			"Sequence with error (but first char -> err) must be inside seq in gen_read (PairedEnd, reverse_complement -> read1). Try $i";
		is index($seq, $r3_f1), $frag_pos + $frag_size - $read->read_size + 1,
			"Position returned + fragment size must be equal to index in gen_read (PairEnd, reverse_complement -> read1). Try $i";
	}
}

sub normality : Tests(1) {
	my $test = shift;
	my $read = $test->default_read;

	SKIP: {
		eval { require Statistics::Normality };
		skip 'Statistics::Normality not installed', 1 if $@;
		
		my @dist;
		push @dist => ($read->_random_half_normal - 2 * $read->read_size) for 1..100;

		my $pval = Statistics::Normality::shapiro_wilk_test(\@dist);
		ok $pval >= 0.05,
			"Shapiro wilk test: pval ($pval) must be greater than alpha level (0.05) to accept the null-hypothesis";
	}
}

1;
