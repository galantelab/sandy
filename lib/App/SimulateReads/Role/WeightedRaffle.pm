package App::SimulateReads::Role::WeightedRaffle;
# ABSTRACT: Extends class with weighted raffle.

use App::SimulateReads::Base 'role';

requires '_build_weights';

# VERSION

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
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
	isa        => 'My:IntGt0',
	builder    => '_build_max_weight',
	lazy_build => 1
);

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::WeightedRaffle (Role)
#       METHOD: _build_num_weights (BUILDER)
#   PARAMETERS: Void
#      RETURNS: Int > 0
#  DESCRIPTION: Builds num_weights
#       THROWS: If weights is not builded, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_num_weights {
	my $self = shift;
	my $weights = $self->weights;
	croak "Not found a weights object\n" unless defined $weights;
	return scalar @$weights;
} ## --- end sub _build_num_weights

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::WeightedRaffle (Role)
#       METHOD: _build_max_weight (BUILDER)
#   PARAMETERS: Void
#      RETURNS: Int > 0
#  DESCRIPTION: Builds max_weight
#       THROWS: If weights is not builded, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_max_weight {
	my $self = shift;
	my $weights = $self->weights;
	croak "Not found a weights object\n" unless defined $weights;
	return $weights->[-1]{up};
} ## --- end sub _build_max_weight

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::WeightedRaffle (Role)
#       METHOD: calculate_weights
#   PARAMETERS: $line HashRef[Int]
#      RETURNS: My:Weights
#  DESCRIPTION: Calculates weight based in a hash -> key => weight, giving:
#              	[ { down, up, feature }, { down, up, feature } .. ] 
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
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
} ## --- end sub calculate_weights

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::WeightedRaffle (Role)
#       METHOD: weighted_raffle
#   PARAMETERS: Void
#      RETURNS: $self->_search()
#  DESCRIPTION: Makes a binary search on the intervals between the weights. The
#               bigger the interval bigger the weight. It begins by making a
#               raffle on the sum of weights, then calls _search that searches
#               for the feature whose value hit the interval
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: _search
#===============================================================================
sub weighted_raffle {
	my $self = shift;
	my $range = int(rand($self->max_weight + 1));
	return $self->_search(0, $self->num_weights - 1, $range);
} ## --- end sub weighted_raffle
 
#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::WeightedRaffle (Role)
#       METHOD: _search (PRIVATE)
#   PARAMETERS: $min_index Int >= 0, $max_index Int > 0, $range Int > 0
#      RETURNS: $weight->{feature} when found
#  DESCRIPTION: Binary search
#       THROWS: If $min_index greater the $max_index, which may not occur, throws
#               an exception
#     COMMENTS: none
#     SEE ALSO: weighted_raffle
#===============================================================================
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
} ## --- end sub _search
