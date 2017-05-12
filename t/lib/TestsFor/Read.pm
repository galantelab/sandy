#
#===============================================================================
#
#         FILE: Read.pm
#
#  DESCRIPTION: Tests for 'Read' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/07/2017 01:49:49 AM
#     REVISION: ---
#===============================================================================

package TestsFor::Read;

use Test::Most;
use base 'TestsFor';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_read');
	$class->mk_classdata('default_attr');
	$class->mk_classdata('seq');
	$class->mk_classdata('seq_len');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	my %default_attr = (
		sequencing_error => 0.1,
		read_size        => 10,
		%child_arg
	);

	my $seq = 'TGACCCGCTAACCTCAGTTCTGCAGCAGTAACAACTGCCGTATCTGGACTTTCCTAATACCTCGCATAGTCCGTCCCCTCGCGCGGCAAGAGGTGCGGCG';

	$test->default_attr(\%default_attr);
	$test->default_read($test->class_to_test->new(%default_attr));
	$test->seq($seq);
	$test->seq_len(length $seq);
}

sub constructor : Tests(6) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $read = $test->default_read;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $read, $attr;
		is $read->$attr, $value,"The value for $attr shold be correct";
	}

	my %attrs = %default_attr;
	for my $attr (qw/sequencing_error read_size/) {
		$attrs{$attr} = -1.0;
		throws_ok { $class->new(%attrs) }
		qr/must be greater than 0/,
			"Setting $attr to less than zero should fail";
	}
}

sub subseq_attr : Test(10) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $read->read_size;

	for my $fun (qw/subseq subseq_rand/) {
		throws_ok {$read->$fun($seq, $seq_len, $slice_len, 0)}	
		qr/must be a reference to a SCALAR/,
			"Setting a non-scalar reference to a seq should fail in $fun";

		throws_ok {$read->$fun(\$seq, $seq_len, -1, 0)}
		qr/must be greater than 0/,
			"Setting a slice_len to less or equal to zero should fail in $fun";

		throws_ok {$read->$fun(\$seq, -1, $slice_len, 0)}
		qr/must be greater than 0/,
			"Setting a seq_len to less or equal to zero should fail in $fun";

		throws_ok {$read->$fun(\$seq, $seq_len, $seq_len + 1, 0)}
		qr/slice_len \(\d+\) greater than seq_len \(\d+\)/,
			"Setting a slice_len greater than seq_len should return undef";
	}

	throws_ok {$read->subseq(\$seq, $seq_len, $slice_len, -1)}
	qr/must be greater than 0/,
		"Setting a pos to less or equal to zero should fail in subseq";
	
	my $pos =  $seq_len - $slice_len + 1;
	throws_ok {$read->subseq(\$seq, $seq_len, $slice_len, $pos)}
	qr/\($slice_len \+ $pos\) <= $seq_len/,
		"Setting a pos + slicelen > seq_len should fail";
}

sub subseq_seq : Test(5) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $read->read_size;

	for my $fun (qw/subseq subseq_rand/) {
		my ($read_seq, $pos) = $read->$fun(\$seq, $seq_len, $slice_len, 0);

		is length($read_seq), 10,
			"Setting a slice_len ($slice_len) should return a seq ($slice_len) in $fun";

		ok index($seq, $read_seq) >= 0,
			"Read sequence must be inside seq in $fun";

	}

	my ($read_seq, $pos) = $read->subseq_rand(\$seq, $seq_len, $slice_len);
	is index($seq, $read_seq), $pos,
		"Position returned in subseq_rand ($pos) should be equal to postion in index";
}

sub subseq_err : Test(40) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $read->read_size;
	
	for my $fun (qw/subseq subseq_rand/) {
		my @subseq;
		for (0..9) {
			my ($seq_t, $pos) = $read->$fun(\$seq, $seq_len, $slice_len, $_ * 10);
			$read->update_count_base($read->read_size);
			$read->insert_sequencing_error(\$seq_t);
			push @subseq => $seq_t;
		}
		
		my $i = 0;
		for (@subseq) {
			$i++;
			ok index($seq, $_) < 0,
				"Sequence with error must be outside seq in $fun Try $i";
			my $seq_t = substr $_, 0, $slice_len - 1;
			ok index($seq, $seq_t) >= 0,
				"Sequence with error (but last char -> err) must be inside seq in $fun Try $i";
		}
	}
}

sub reverse_complement :Test(2) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $read->read_size;

	throws_ok {$read->reverse_complement($seq)}
	qr/must be a reference to a SCALAR/,
		"Setting a non-scalar reference to a seq should fail in reverse_complement";
	
	my $seq_rev1 = $seq;
	$read->reverse_complement(\$seq_rev1);
	my $seq_rev2 = reverse $seq;
	$seq_rev2 =~ tr/atcgATCG/tagcTAGC/;

	ok $seq_rev1 eq $seq_rev2,
		"The reverse_complement must return the reverse complement";
}

1;
