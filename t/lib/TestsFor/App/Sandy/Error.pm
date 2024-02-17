package TestsFor::App::Sandy::Error;
# ABSTRACT: Tests for 'App::Sandy::Error' class

use App::Sandy::Base 'test';
use App::Sandy::RNG;

use autodie;
use base 'TestsFor';

use constant SEED => 17;

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_error');
	$class->mk_classdata('rng');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	$test->default_error($test->class_to_test->new());
	$test->rng(App::Sandy::RNG->new(SEED));
}

sub not_base : Test(16) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $error = $test->default_error;
	my $rng = $test->rng;

	my @bases = (qw/A T C G a t c g/);

	for my $base (@bases) {
		my $not_base = $error->randb($base, $rng);
		isnt $base, $not_base,
			"base '$base' should not be equal ~base '$not_base'";
		like $not_base, qr/[ATCGatcg]/,
			"~base '$not_base' should be in [ATCGatcg]";
	}
}
