package TestsFor::App::Sandy::Read::PairedEnd;
# ABSTRACT: Tests for 'App::Sandy::Read::PairedEnd' class

use App::Sandy::Base 'test';
use base 'TestsFor::App::Sandy::Read';

sub startup : Tests(startup) {
	my $test = shift;
	my $class = ref $test;
	$test->SUPER::startup;
	$class->mk_classdata('table_read');
}

sub setup : Tests(setup) {
	my $test = shift;

	my %default_attr = (
		fragment_mean    => 50,
		fragment_stdd    => 10
	);

	$test->SUPER::setup(%default_attr);

	my $seq = $test->seq;
	$test->table_read(App::Sandy::PieceTable->new(orig => \$seq));
	$test->table_read->calculate_logical_offset;
}

sub constructor : Tests(8) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $read = $test->default_read;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $read, $attr;
		is $read->$attr, $value,"The value for $attr shold be correct";
	}
}

sub gen_read : Tests(61) {
	my $test = shift;

	my $read = $test->default_read;
	my $seq = $test->seq;
	my $read_size = $test->slice_len;
	my $table = $test->table_read;

	my $err = 0;
	for (1..100) {
		my ($r1_ref, $r2_ref, $attr) = $read->gen_read($table, $table->logical_len, $read_size, 1);
		$err++ unless defined $$r1_ref && defined $$r2_ref;
	}

	ok $err == 0, "100 tries: It must not give error";

	for my $i (0..9) {
		#For leader strand
		my ($r1_ref, $r2_ref, $attr) = $read->gen_read($table, $table->logical_len, $read_size, 1);
		ok index($seq, $$r1_ref) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd -> read1). Try $i";
		my $r1_l1 = substr $$r1_ref, 0, $read_size - 1;
		ok index($seq, $r1_l1) >= 0,
			"Sequence with error (but last char -> err) must be inside seq in gen_read (PairedEnd -> read1). Try $i";
		is index($seq, $r1_l1), $attr->{start} - 1,
			"Position returned must be equal to index in gen_read (PairEnd -> read1). Try $i";

		$read->reverse_complement($r2_ref);
		ok index($seq, $$r2_ref) < 0,
			"Sequence with error must be outside seq in gen_read (PairEnd -> read2). Try $i";
		my $r2_f1 = substr $$r2_ref, 1, $read_size - 1;
		ok index($seq, $r2_f1) >= 0,
			"Sequence with error (but first char -> err) must be inside seq in gen_read (PairedEnd -> read2). Try $i";
		is index($seq, $r2_f1), $attr->{read_start_ref},
			"Position returned + fragment size must be equal to index in gen_read (PairEnd -> read2). Try $i";
	}
}
