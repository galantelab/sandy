package App::Sandy::Base;
# ABSTRACT: Policy and base module to App::Sandy project.

use 5.014;
use strict;
use warnings FATAL => 'all';
use utf8 ();
use feature ();
use true ();
use Carp ();
use IO::Handle;
use Try::Tiny ();
use Hook::AfterRuntime;
use Import::Into;
use Data::OptList;
use Module::Runtime 'use_module';
use namespace::autoclean;

our $VERSION = '0.23'; # VERSION

BEGIN {
	$SIG{'__DIE__'} = sub {
		if($^S) {
			return;
		}
		Carp::confess(@_) if $ENV{DEBUG};
		die(@_);
	};
}

# To ensure STDERR will be utf8 encoded
binmode STDERR, ":encoding(utf8)";

# Enable auto-flush
STDERR->autoflush(1);

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
	feature->import(':5.14');
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
		if ($opt eq 'dont_clean') {
			if (!$opt_args) {
				Carp::carp "ignoring dont_clean option without arrayref of subroutine names to keep";
				next;
			}
			push @no_clean, @$opt_args;
		} elsif ($opt eq 'class') {
			require Moose;
			require MooseX::StrictConstructor;
			require MooseX::UndefTolerant;
			require App::Sandy::Types;
			Moose->import({into=>$caller});
			MooseX::StrictConstructor->import({into=>$caller});
			MooseX::UndefTolerant->import({into=>$caller});
			App::Sandy::Types->import({into=>$caller});
			after_runtime {
				$caller->meta->make_immutable;
			}
		} elsif ($opt eq 'role') {
			require Moose::Role;
			require App::Sandy::Types;
			Moose::Role->import({into=>$caller});
			App::Sandy::Types->import({into=>$caller});
		} elsif ($opt eq 'test') {
			use_module('Test::Most')->import::into($caller);
			if ($opt_args) {
				for my $opt_arg (@$opt_args) {
					if ($opt_arg eq 'class_load') {
						use_module('Test::Class::Load')->import::into($caller, 't/lib');
					} elsif ($opt_arg eq 'class_base') {
						my @classes = qw(Test::Class Class::Data::Inheritable);
						use_module('base')->import::into($caller, @classes);
					} else {
						Carp::carp "Ignoring unknown test option '$_'";
					}
				}
			}
		} else {
			Carp::carp "Ignoring unknown import option '$_'";
		}
	}

	#This must come after anything else that might change warning
	# levels in the caller (e.g. Moose)
	warnings->import('FATAL'=>'all');

	namespace::autoclean->import(
		-cleanee => $caller,
		-except  => \@no_clean,
	);

	return;
}

1; ## --- end module App::Sandy::Base

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Base - Policy and base module to App::Sandy project.

=head1 VERSION

version 0.23

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
