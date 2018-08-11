package TestsFor::App::Sandy::Read;
# ABSTRACT: Tests for 'App::Sandy::Read' class

use App::Sandy::Base 'test';
use App::Sandy::PieceTable;
#use Data::Dumper;
use base 'TestsFor';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_read');
	$class->mk_classdata('default_attr');
	$class->mk_classdata('seq');
	$class->mk_classdata('seq_len');
	$class->mk_classdata('table');
	$class->mk_classdata('table_seq');
	$class->mk_classdata('slice_len');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	my %default_attr = (
		sequencing_error => 0.1,
		%child_arg
	);

	my $seq = 'TGACCCGCTAACCTCAGTTCTGCAGCAGTAACAACTGCCGTATCTGGACTTTCCTAATACCTCGCATAGTCCGTCCCCTCGCGCGGCAAGAGGTGCGGCG';
	my $table_seq = "A large span of text";

	$test->default_attr(\%default_attr);
	$test->default_read($test->class_to_test->new(%default_attr));
	$test->seq($seq);
	$test->seq_len(length $seq);
	$test->slice_len(10);
	$test->table(App::Sandy::PieceTable->new(orig => \$table_seq));
}

sub constructor : Tests(4) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $read = $test->default_read;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $read, $attr;
		is $read->$attr, $value,"The value for $attr shold be correct";
	}
}

sub subseq_seq : Test(5) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $test->slice_len;

	my ($read_seq1_ref, $pos1) = $read->subseq(\$seq, $seq_len, $slice_len, 0);

	is length($$read_seq1_ref), 10,
		"Setting a slice_len ($slice_len) should return a seq ($slice_len) in subseq";

	ok index($seq, $$read_seq1_ref) >= 0,
		"Read sequence must be inside seq in subseq";

	my ($read_seq2_ref, $pos2) = $read->subseq_rand(\$seq, $seq_len, $slice_len);

	is length($$read_seq2_ref), 10,
		"Setting a slice_len ($slice_len) should return a seq ($slice_len) in subseq_rand";

	ok index($seq, $$read_seq2_ref) >= 0,
		"Read sequence must be inside seq in subseq";

	my ($read_seq3_ref, $pos3) = $read->subseq_rand(\$seq, $seq_len, $slice_len);
	is index($seq, $$read_seq3_ref), $pos3,
		"Position returned in subseq_rand ($pos3) should be equal to postion in index";
}

sub subseq_err : Test(60) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $test->slice_len;

	for my $i (0..9) {
		my ($seq_t_ref, $pos) = $read->subseq_rand(\$seq, $seq_len, $slice_len);
		$read->insert_sequencing_error($seq_t_ref, $slice_len);

		ok index($seq, $$seq_t_ref) < 0,
			"Sequence with error must be outside seq in subseq_rand Try $i";
		my $seq_t_noerr = substr $$seq_t_ref, 0, $slice_len - 1;
		ok index($seq, $seq_t_noerr) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in subseq_rand Try $i";
	}

	for my $i (0..9) {
		my ($seq_t_ref, $pos) = $read->subseq(\$seq, $seq_len, $slice_len, $i * 10);
		$read->insert_sequencing_error($seq_t_ref, $slice_len);

		ok index($seq, $$seq_t_ref) < 0,
			"Sequence with error must be outside seq in subseq Try $i";
		my $seq_t_noerr = substr $$seq_t_ref, 0, $slice_len - 1;
		ok index($seq, $seq_t_noerr) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in subseq_rand Try $i";
	}

	# Check if sequencing_error = 0 won't insert error
	my %attr = %{ $test->default_attr };
	$attr{sequencing_error} = 0;
	my $read2 = $test->class_to_test->new(%attr);

	for my $i (0..9) {
		my ($seq_t_ref, $pos) = $read2->subseq_rand(\$seq, $seq_len, $slice_len);
		$read2->insert_sequencing_error($seq_t_ref, $slice_len);
		ok index($seq, $$seq_t_ref) >= 0,
			"Sequence with sequencing_error = 0 must be inside seq in subseq_rand Try $i";
	}

	for my $i (0..9) {
		my ($seq_t_ref, $pos) = $read2->subseq(\$seq, $seq_len, $slice_len, $i * 10);
		$read2->insert_sequencing_error($seq_t_ref, $slice_len);
		ok index($seq, $$seq_t_ref) >= 0,
			"Sequence with sequencing_error = 0 must be inside seq in subseq Try $i";
	}
}

sub reverse_complement :Test(1) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $seq_len = $test->seq_len;
	my $slice_len = $test->slice_len;

	my $seq_rev1 = $seq;
	$read->reverse_complement(\$seq_rev1);
	my $seq_rev2 = reverse $seq;
	$seq_rev2 =~ tr/atcgATCG/tagcTAGC/;

	ok $seq_rev1 eq $seq_rev2,
		"The reverse_complement must return the reverse complement";
}

sub subseq_rand_ptable : Test(20) {
	my $test = shift;

	my $read = $test->default_read;
	my $table = $test->table;
	my $seq = $test->table_seq;
	my $alt_seq = "A span of English text";

	# Try to remove large
	$table->delete(2, 6, "large/-");

	# Try to insert 'English'
	my $add = "English ";
	$table->insert(\$add, 16, "-/English");

#	diag Dumper($table->piece_table);

	# Initialize
	$table->calculate_logical_offset;
	my $len = 10;

	for my $i (1..10) {
		my ($seq_ref, $attr) = $read->subseq_rand_ptable($table,
			$table->logical_len, $len, $len);
		my $true_seq = substr $alt_seq, $attr->{start} - 1, $len;
		ok $$seq_ref eq $true_seq,
			"Try $i: subseq_rand_ptable returned correct seq = '$$seq_ref'";
#		$" = ", ";
#		diag sprintf "[%s] %s\n" => $$seq_ref, join "; ", map { "pos=$_->{pos},offset=$_->{offset},rel=$_->{pos_rel}:$_->{annot}" } @$annot;
	}

	# A large span of text
	my $alt_seq2 = "A span of English Ponga";

	# Try to chnage text to Ponga
	$table->change(\"Ponga", 16, 4, "text/Ponga");
	$table->calculate_logical_offset;

#	diag Dumper($table->piece_table);

	for my $i (1..10) {
		my ($seq_ref, $attr) = $read->subseq_rand_ptable($table,
			$table->logical_len, $len, $len);
		my $true_seq = substr $alt_seq2, $attr->{start} - 1, $len;
		ok $$seq_ref eq $true_seq,
			"Try $i: subseq_rand_ptable returned correct seq = '$$seq_ref'";
	}
}
