package App::SimulateReads::Role::WeightedRaffle;
# ABSTRACT: Extends class with weighted raffle.

use App::SimulateReads::Base 'role';

requires '_build_weights';

# VERSION

has 'weights'     => (
	is         => 'ro',
	isa        => 'My:Weights',
	builder    => '_build_weights',
	lazy_build => 1
);

has 'num_weights' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	builder    => '_build_num_weights',
	lazy_build => 1
);

has 'max_weight'  => (
	is         => 'ro',
	isa        => 'My:IntGe0',
	builder    => '_build_max_weight',
	lazy_build => 1
);

sub _build_num_weights {
	my $self = shift;
	my $weights = $self->weights;
	croak "Not found a weights object\n" unless defined $weights;
	return scalar @$weights;
}

sub _build_max_weight {
	my $self = shift;
	my $weights = $self->weights;
	croak "Not found a weights object\n" unless defined $weights;
	return $weights->[-1]{up};
}

sub calculate_weights {
	my ($self, $line) = @_;

	my @weights;
	my $left = 0;

	for my $feature (keys %$line) {
		my %weight = (
			down    => $left,
			up      => $left + $line->{$feature} - 1,
			feature => $feature
		);
		$left += $line->{$feature};
		push @weights => \%weight;
	}

	return \@weights;
}

sub weighted_raffle {
	my $self = shift;
	my $range = int(rand($self->max_weight + 1));
	return $self->_search(0, $self->num_weights - 1, $range);
}

sub _search {
	my ($self, $min_index, $max_index, $range) = @_;

	if ($min_index > $max_index) {
		croak "Random feature not found";
	}

	my $selected_index = int(($min_index + $max_index) / 2);
	my $weight = $self->weights->[$selected_index];

	if ($range >= $weight->{down} && $range <= $weight->{up}) {
		return $weight->{feature};
	}
	elsif ($range > $weight->{down}) {
		return $self->_search($selected_index + 1,
			$max_index, $range);
	} else {
		return $self->_search($min_index,
			$selected_index - 1, $range);
	}
}
