package TestsFor;
# ABSTRACT: Uses the TestsFor:: namespace to ensure that tests do not try to use a namespace in use by another package.

use App::Sandy::Base test => [qw(class_base)];

INIT {
	__PACKAGE__->mk_classdata('class_to_test');
	Test::Class->runtests;
}

sub startup  : Tests(startup) {
	my $test = shift;
	my $class = ref $test;
	$class =~ s/^TestsFor:://;
	eval "use $class";
	die $@ if $@;
	$test->class_to_test($class);
}

sub setup    : Tests(setup)    {}

sub teardown : Tests(teardown) {}

sub shutdown : Tests(shutdown) {}

## --- end class TestsFor
