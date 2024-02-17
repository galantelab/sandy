package TestsFor::App::Sandy::Error::Phred;
# ABSTRACT: Tests for 'App::Sandy::Error::Phred' class

use App::Sandy::Base 'test';
use App::Sandy::RNG;
use base 'TestsFor::App::Sandy::Error';

use autodie;
use base 'TestsFor';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	$test->default_error($test->class_to_test->new());
}

sub insert_error : Tests(3) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $error = $test->default_error;
	my $rng = $test->rng;

	my $read = 'ATCG' x 10;
	my %dep = (
		'!' => {
			min => 39, max => 41,
			msg => sub{ "n_errors '$_[0]' should be between ]39,41[" }
		},
		'$' => {
			min => 14, max => 26,
			msg => sub{ "n_errors '$_[0]' should be between ]14,26[" }
		},
		'%' => {
			min => 10, max => 23,
			msg => sub{ "n_errors '$_[0]' should be between ]10,23[" }
		}
	);

	for my $char (keys %dep) {
		my $quality = $char x 40;

		my $errors_a = $error->insert_sequencing_error(\$read,
			\$quality, 40, $rng);
		my $n_errors = scalar @$errors_a;

		ok $n_errors < $dep{$char}{max} && $n_errors > $dep{$char}{min},
			$dep{$char}{msg}->($n_errors);
	}
}
