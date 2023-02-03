package App::Sandy::Rand;
# ABSTRACT: Generates random numbers

use App::Sandy::Base 'class';

use Math::GSL::RNG qw/$gsl_rng_ranlxd2/;
use Math::GSL::Randist qw/gsl_ran_gaussian/;

# VERSION

has 'seed' => (
	is         => 'ro',
	isa        => 'Int',
	required   => 1
);

has '_rng' => (
	is         => 'ro',
	isa        => 'Math::GSL::RNG',
	builder    => '_build_rng',
	lazy_build => 1
);

sub _build_rng {
	my $self = shift;
	return Math::GSL::RNG->new($gsl_rng_ranlxd2, $self->seed);
}

sub get {
	my ($self, $n) = @_;
	my ($rand) = $self->_rng->get;
	return $rand % $n;
}

sub get_norm {
	my ($self, $mean, $stdd) = @_;
	my $z = gsl_ran_gaussian($self->_rng->raw, $stdd);
	return $mean + int($z + 0.5);
}

sub DEMOLISH {
	my ($self, $global) = @_;
	$self->_rng->free unless $global;
}
