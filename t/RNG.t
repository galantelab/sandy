# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Read.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 3;
BEGIN { use_ok('App::Sandy::RNG') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
my @methods = (
qw/
	set	
	max
	min
	size
	name
	get
	uniform
	uniform_pos
	ran_gaussian
	ran_gaussian_ratio_method
	ran_gaussian_pdf
	ran_ugaussian
	ran_ugaussian_ratio_method
	ran_ugaussian_pdf
/);

my $r = App::Sandy::RNG->new(1717);

isa_ok($r, 'App::Sandy::RNG');
can_ok($r, @methods);

#my $seq = 'Thiago';
#is('Thia', $r->subseq($seq, length $seq, 0), "Thiago (0,4) = Thia");
#is('hiag', $r->subseq($seq, length $seq, 1), "Thiago (1,4) = hiag");
#is('iago', $r->subseq($seq, length $seq, 2), "Thiago (2,4) = iago");

#for (1..10) {
	#my ($slice, $pos) = $r->subseq_rand($seq, length $seq);
	#is(substr($seq, $pos, 4), $slice, "Thiago (rand, 4) should be substr(rand, 4)");
#}

#$seq = 'ATCGATCGAT';
#like($r->subseq_with_error($seq, length $seq, 0), qr/ATCG/, "Expected ATCG");
#like($r->subseq_with_error($seq, length $seq, 4), qr/[^A]TCG/, "Expected not A--TCG");
#like($r->subseq_with_error($seq, length $seq, 4), qr/A[^T]CG/, "Expected A--not T--CG");

#my ($slice, $pos) = $r->subseq_rand_with_error($seq, length $seq);
#is(substr($seq, $pos, 2), substr($slice, 0, 2), "ATCGATCGAT (rand, 4) should be substr(rand, 4)");
#($slice, $pos) = $r->subseq_rand_with_error($seq, length $seq);
#isnt(substr($seq, $pos, 4), $slice, "subseq rand with error should fail");
#is(substr($seq, $pos, 3), substr($slice, 0, 3), "subseq rand with no error is equal to seq substr")
