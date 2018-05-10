package App::Sandy::WeightedRaffle;
# ABSTRACT: Weighted raffle interface.

use App::Sandy::Base 'class';

with 'App::Sandy::Role::BSearch';

# VERSION

has 'keys' => (
	traits     => ['Array'],
	is         => 'ro',
	isa        => 'ArrayRef',
	required   => 1,
	handles    => { _get_key => 'get' }
);

has 'weights' => (
	is         => 'ro',
	isa        => 'ArrayRef[Int]',
	required   => 1
);

has '_weights' => (
	is         => 'ro',
	isa        => 'My:Weights',
	builder    => '_build_weights',
	lazy_build => 1
);

has '_num_weights' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	builder    => '_build_num_weights',
	lazy_build => 1
);

has '_max_weight' => (
	is         => 'ro',
	isa        => 'My:IntGe0',
	builder    => '_build_max_weight',
	lazy_build => 1
);

sub BUILD {
	my $self = shift;

	my $weights = $self->weights;
	my $keys = $self->keys;

	if (scalar(@$weights) != scalar(@$keys)) {
		croak "Number of weights must be equal to the number of keys";
	}
}

sub _build_num_weights {
	my $self = shift;
	my $weights = $self->_weights;
	return scalar @$weights;
}

sub _build_max_weight {
	my $self = shift;
	my $weights = $self->_weights;
	return $weights->[-1]{up};
}

sub _build_weights {
	my $self = shift;
	my $weights = $self->weights;

	my @weights_offset;
	my $left = 0;

	for (my $i = 0; $i < @$weights; $i++) {
		my %weight = (
			down => $left,
			up   => $left + $weights->[$i] - 1
		);

		$left += $weights->[$i];
		push @weights_offset => \%weight;
	}

	return \@weights_offset;
}

sub weighted_raffle {
	my $self = shift;

	# Raffle between 0 and max weight
	my $range = int(rand($self->_max_weight + 1));

	# Look for the index where the range is
	my $index = $self->with_bsearch($range, $self->_weights,
		$self->_num_weights, \&_cmp);

	if (not defined $index) {
		croak "Random index not found at range = $range";
	}

	# Do it!
	return $self->_get_key($index);
}

sub _cmp {
	# State the function to compare at bsearch
	my ($range, $weight) = @_;

	if ($range >= $weight->{down} && $range <= $weight->{up}) {
		return 0;
	}
	elsif ($range > $weight->{down}) {
		return 1;
	} else {
		return -1;
	}
}
