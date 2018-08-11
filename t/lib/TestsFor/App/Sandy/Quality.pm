package TestsFor::App::Sandy::Quality;
# ABSTRACT: Tests for 'App::Sandy::Quality' class

use App::Sandy::Base 'test';
use autodie;
use base 'TestsFor';

use constant {
	SEQ_SYS       => "poisson",
	QUALITY_SIZE  => 10
};

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_quality');
	$class->mk_classdata('default_attr');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	my %default_attr = (
		quality_profile => SEQ_SYS,
		%child_arg
	);

	$test->default_attr(\%default_attr);
	$test->default_quality($test->class_to_test->new(%default_attr));
}

sub constructor : Tests(2) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $quality = $test->default_quality;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $quality, $attr;
		is lc $quality->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub gen_quality : Test(10) {
	my $test = shift;

	my $size = QUALITY_SIZE;
	my $class = $test->class_to_test;
	my $quality = $test->default_quality;

	for my $i (1..10) {
		my $q = $quality->gen_quality($size);
		is length $$q, $size,
			"quality length should be equal read_size. Try $i";
	}
}

