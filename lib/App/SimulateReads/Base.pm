package App::SimulateReads::Base;
# ABSTRACT: Policy and base module to App::SimulateReads project.

use 5.010;
use strict;
use warnings FATAL => 'all';
no if $] >= 5.018, warnings => "experimental::smartmatch";
use utf8 ();
use feature ();
use true ();
use Carp ();
use Try::Tiny ();
use Hook::AfterRuntime;
use Import::Into;
use Data::OptList;
use Module::Runtime 'use_module';
use namespace::autoclean;

# VERSION

BEGIN {
	$SIG{'__DIE__'} = sub {
		if($^S) {
			return;
		}
		Carp::confess(@_) if $ENV{DEBUG};
		die(@_);
	};
}

binmode STDERR, ":encoding(utf8)";
our $LOG_VERBOSE = 1;

sub log_msg {
	my ($msg) = @_;
	return if not defined $msg;
	chomp $msg;
	say STDERR $msg if $LOG_VERBOSE;
}

sub import {
	my ($class, @opts) = @_;
	my $caller = caller;

	# Import as in Moder::Perl
	strict->import;
	feature->import(':5.10');
	utf8->import($caller);
	true->import;
	Carp->import::into($caller);
	Try::Tiny->import::into($caller);

	# Custom handy function
	do {
		no strict 'refs'; ## no critic
		*{"${caller}\:\:log_msg"} = \&log_msg;
		*{"${caller}\:\:LOG_VERBOSE"} = \$LOG_VERBOSE;
	};

	@opts = @{
		Data::OptList::mkopt(
			\@opts,
		)
	};

	my @no_clean;
	for my $opt_spec (@opts) {
		my ($opt, $opt_args) = @$opt_spec;
		given ($opt) {
			when ('dont_clean') {
				if (!$opt_args) {
					Carp::carp "ignoring dont_clean option without arrayref of subroutine names to keep";
					next;
				}
				push @no_clean, @$opt_args;
			}
			when ('class') {
				require Moose;
				require MooseX::StrictConstructor;
				require MooseX::UndefTolerant;
				require App::SimulateReads::Types;
				Moose->import({into=>$caller});
				MooseX::StrictConstructor->import({into=>$caller});
				MooseX::UndefTolerant->import({into=>$caller});
				App::SimulateReads::Types->import({into=>$caller});
				after_runtime {
					$caller->meta->make_immutable;
				}
			}
			when ('role') {
				require Moose::Role;
				require App::SimulateReads::Types;
				Moose::Role->import({into=>$caller});
				App::SimulateReads::Types->import({into=>$caller});
			}
			when ('test') {
				use_module('Test::Most')->import::into($caller);
				if ($opt_args) {
					for (@$opt_args) {
						when ('class_load') {
							use_module('Test::Class::Load')->import::into($caller, 't/lib');
						}
						when ('class_base') {
							my @classes = qw(Test::Class Class::Data::Inheritable);
							use_module('base')->import::into($caller, @classes);
						}
						default {
							Carp::carp "Ignoring unknown test option '$_'";
						}
					}
				}
			}
			default {
				Carp::carp "Ignoring unknown import option '$_'";
			}
		}
	}

	#This must come after anything else that might change warning
	# levels in the caller (e.g. Moose)
	warnings->import('FATAL'=>'all');
	warnings->unimport('experimental::smartmatch') if $] >= 5.018;

	namespace::autoclean->import(
		-cleanee => $caller,
		-except  => \@no_clean,
	);

	return;
}

1; ## --- end module App::SimulateReads::Base
