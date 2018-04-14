package App::SimulateReads::WeightedRaffle;
# ABSTRACT: Weighted raffle interface.

use App::SimulateReads::Base 'class';

# VERSION

has 'weights' => (
	is         => 'ro',
	isa        => 'HashRef[Int]',
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
	my $line = $self->weights;

	my @weights;
	my $left = 0;

	for my $feature (sort keys %$line) {
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
	my $range = int(rand($self->_max_weight + 1));
	return $self->_search(0, $self->_num_weights - 1, $range);
}

sub _search {
	my ($self, $min_index, $max_index, $range) = @_;

	if ($min_index > $max_index) {
		die "Random feature not found";
	}

	my $selected_index = int(($min_index + $max_index) / 2);
	my $weight = $self->_weights->[$selected_index];

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
