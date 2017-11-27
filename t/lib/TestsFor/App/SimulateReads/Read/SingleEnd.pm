package TestsFor::App::SimulateReads::Read::SingleEnd;
# ABSTRACT: Tests for 'App::SimulateReads::Read::SingleEnd' class

use App::SimulateReads::Base 'test';
use base 'TestsFor::App::SimulateReads::Read';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;
	$test->SUPER::setup;
}

sub gen_read : Tests(51) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	throws_ok { ${ $read->gen_read(\$seq, $read->read_size - 1, 1) } }
	qr/must be greater or equal to read_size/,
		"Sequence length lesser than read_size must return error";
	
	for my $i (0..9) {
		my ($r1_ref, $pos1) = $read->gen_read(\$seq, $seq_len, 1);
		ok index($seq, $$r1_ref) < 0,
			"Sequence with error must be outside seq in gen_read (SingleEnd). Try $i";
		my $seq_t1 = substr $$r1_ref, 0, $read->read_size - 1;
		ok index($seq, $seq_t1) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (SingleEnd). Try $i";
		is index($seq, $seq_t1), $pos1,
			"Position returned must be equal to index in gen_read (SingleEnd). Try $i";

		my ($r2_ref, $pos2) = $read->gen_read(\$seq, $seq_len, 0);
		my $seq_t2 = substr $$r2_ref, 0, $read->read_size - 1;
		$read->reverse_complement(\$seq_t2);
		ok index($seq, $seq_t2) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (SingleEnd, reverse_complement). Try $i";

		is index($seq, $seq_t2), $pos2 + 1,
			"Position returned must be equal to index in gen_read (SingleEnd, reverse_complement). Try $i";
	}
}

## --- end class TestsFor::Read::SingleEnd
