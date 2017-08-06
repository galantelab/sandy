#
#===============================================================================
#
#         FILE: TestFor.pm
#
#  DESCRIPTION: Uses the TestsFor:: namespace to ensure that my test classes do not
#               try to use a namespace in use by another package.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/07/2017 01:34:45 AM
#     REVISION: ---
#===============================================================================

package TestsFor;

use My::Base qw(test test_class_base);

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
