#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: Tests for 'Read::SingleEnd' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/08/2017 10:22:06 PM
#     REVISION: ---
#===============================================================================

package TestsFor::Read::SingleEnd;

use Test::Most;
use base 'TestsFor::Read';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;
	$test->SUPER::setup;
}

sub gen_read : Tests(21) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;

	ok not($read->gen_read(\$seq, $read->read_size - 1)),
		"Sequence length lesser than read_size must return undef";
	
	my @subseq;
	push @subseq => $read->gen_read(\$seq, $seq_len) for 0..9;
		
	my $i = 0;
	for (@subseq) {
		$i++;
		ok index($seq, $_) < 0,
			"Sequence with error must be outside seq in gen_read (SingleEnd). Try $i";
		my $seq_t = substr $_, 0, $read->read_size - 1;
		ok index($seq, $seq_t) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (SingleEnd). Try $i";
	}
}

1;
