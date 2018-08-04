package App::Sandy::Role::RNorm;
# ABSTRACT: Random normal distribution

use App::Sandy::Base 'role';
use Math::Random 'random_normal';

sub with_random_half_normal {
	my ($self, $mean, $stdd) = @_;
	return abs(int(random_normal(1, $mean, $stdd)));
}
