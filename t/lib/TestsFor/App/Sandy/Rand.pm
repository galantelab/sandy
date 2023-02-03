package TestsFor::App::Sandy::Rand;
# ABSTRACT: Tests for 'App::Sandy::Rand' class

use App::Sandy::Base 'test';
use base 'TestsFor';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;

	my $class = ref $test;

	$class->mk_classdata('default_rand');
	$class->mk_classdata('default_seed');
}

sub setup : Tests(setup) {
	my $test = shift;
	$test->SUPER::setup;

	$test->default_seed(27);
	$test->default_rand($test->class_to_test->new(seed => 27));
}

sub constructor : Tests(2) {
	my $test = shift;

	my $class = $test->class_to_test;

	my $rand = $test->default_rand;
	my $seed = $test->default_seed;

	can_ok $rand, "seed";
	is $rand->seed, $seed;
}

sub get : Test(10) {
	my $test = shift;
	my $rand = $test->default_rand;

	for (1..10) {
		my $r = $rand->get(10);
		ok $r >= 0 && $r < 10;
	}
}

sub get_norm : Test(1) {
	my $test = shift;
	my $rand = $test->default_rand;

	my @stack;

	for (1..100) {
		my $r = $rand->get_norm(350, 50);
		push @stack => $r if $r >= 300 && $r <= 400;
	}

	ok scalar(@stack) >= 60;
}
