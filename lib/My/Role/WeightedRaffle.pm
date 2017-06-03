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
use My::Types;
use Carp 'carp';

requires '_build_weights';

has 'weights' => (
	is         => 'ro',
	isa        => 'My:Weights',
	builder    => '_build_weights',
	lazy_build => 1
);

before 'calculate_weights' => sub {
	my $self = shift;
	my ($line) = pos_validated_list(
		\@_,
		{ isa => 'HashRef[Num]' }
	);
};

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
	my $range = int(rand($self->weights->[-1]{up} + 1));
	return $self->_search(0, $#{ $self->weights }, $range);
}
 
sub _search {
	my ($self, $min_index, $max_index, $range) = @_;

	if ($min_index > $max_index) {
		carp "Random feature not found";
		return;
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

1;
