package App::Sandy::Error;
# ABSTRACT: Base class for error models

use App::Sandy::Base 'class';

# VERSION

has '_not_base' => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_not_base',
	lazy_build => 1
);

sub _build_not_base {
	my %not_base = (
		A => ['T', 'C', 'G'],
		a => ['t', 'c', 'g'],
		T => ['A', 'C', 'G'],
		t => ['a', 'c', 'g'],
		C => ['A', 'T', 'G'],
		c => ['a', 't', 'g'],
		G => ['A', 'T', 'C'],
		g => ['a', 't', 'c']
	);
	return \%not_base;
}

sub randb {
	my ($self, $base, $rng) = @_;
	return $self->_not_base->{$base}[$rng->get_n(3)] || $base;
}
