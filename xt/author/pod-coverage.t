#!/usr/bin/env perl 

use strict;
use warnings;

use Test::Pod::Coverage 1.08;
use Pod::Coverage::TrustPod;

all_pod_coverage_ok({
	coverage_class => 'Pod::Coverage::TrustPod',
	also_private   => [
		qr/.*validate.*/,
		qr/.*command.*/,
		qr/[[:upper:]]+/,
		qw/execute opt_spec/
	]
});
