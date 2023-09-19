package TestsFor::App::Sandy::RNG;
# ABSTRACT: Tests for 'App::Sandy::RNG' class

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
	$test->default_rand($test->class_to_test->new(27));
}

sub constructor : Tests(1) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $rand = $test->default_rand;

	my @methods = (qw/
		set	max min size
		name get uniform uniform_pos
		ran_gaussian ran_gaussian_ratio_method ran_gaussian_pdf ran_ugaussian
		ran_ugaussian_ratio_method ran_ugaussian_pdf get_n get_norm/
	);

	can_ok $rand, @methods;
}

sub get_n : Test(10) {
	my $test = shift;
	my $rand = $test->default_rand;

	for (1..10) {
		my $r = $rand->get_n(10);
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
