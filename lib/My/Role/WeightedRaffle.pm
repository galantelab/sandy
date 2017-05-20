#
#===============================================================================
#
#         FILE: WeightedRaffle.pm
#
#  DESCRIPTION: with 'My::Role::WeightedRaffle';
#               extends class with weighted raffle.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 09-03-2017 19:27:50
#     REVISION: ---
#===============================================================================

package My::Role::WeightedRaffle;

use Moose::Role;
use MooseX::Params::Validate;
use Carp;

sub _calculate_weight {
	my $self = shift;
	my ($line) = pos_validated_list(
		\@_,
		{ isa => 'HashRef[Num]' }
	);

	my @weight;
	my $left = 0;

	for my $feature (keys %$line) {
		my %w = (
			down    => $left,
			up      => $left + $line->{$feature} - 1,
			feature => $feature
		);
		$left += $line->{$feature};
		push @weight => \%w;
	}

	my %pos_weight = (
		acm    => $weight[$#weight]{up},
		weight => \@weight
	);

	return \%pos_weight;
}
 
sub _search {
	my ($self, $weights, $min_index, $max_index, $range) = @_;

	croak "<$weights> argument is not an array ref"
		unless ref($weights) eq "ARRAY";

	if ($min_index > $max_index) {
		carp "Random feature not found";
		return;
	}

	my $selected_index = int(($min_index + $max_index) / 2);
	my $weight = $weights->[$selected_index];

	croak "<$weight> inside @$weights is not a hash ref"
		unless ref($weight) eq "HASH";

	if ($range >= $weight->{down} && $range <= $weight->{up}) {
		return $weight->{feature};
	}
	elsif ($range > $weight->{down}) {
		return $self->_search($weights, $selected_index + 1,
			$max_index, $range);
	} else {
		return $self->_search($weights, $min_index,
			$selected_index - 1, $range);
	}
}

1;
