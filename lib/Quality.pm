#
#===============================================================================
#
#         FILE: Quality.pm
#
#  DESCRIPTION: Analyses a fastq set and generate a weight matrix based on the quality
#               frequence for each position
#
#               use Quality;
#
#               my $q = Quality->new(
#					quality_matrix  => <FILE>,
#					quality_size    => 76
#               );
#
#               my $quality = $q->gen_quality;
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 17-02-2017 18:50:19
#     REVISION: ---
#===============================================================================

package Quality;

use Moose;
use MooseX::StrictConstructor;
use My::Types;
use Carp 'croak';

use namespace::autoclean;

with qw/My::Role::WeightedRaffle My::Role::IO/;

has 'quality_matrix'    => (is => 'ro', isa => 'My:File',   required => 1);
has 'quality_size'      => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_pos'              => (
	is         => 'ro',
	isa        => 'ArrayRef[My:Weights]',
	builder    => '_build_pos',
	lazy_build => 1
);

sub _build_pos {
	my $self = shift;
	my $freq = $self->_get_freq;
	return $self->_get_weight($freq);
}

sub _get_freq {
	my $self = shift;

	my $fh = $self->open($self->quality_matrix);

	# freq [[0]:{'q' => N}, [1]:{'r' => N}, ...]
	my @freq;
	my $prev_len;

	while (<$fh>) {
		chomp;
		my $act_len = length;

		unless (defined $prev_len) {
			$prev_len = $act_len;
			croak "quality_size required is greater than the length at " . $self->quality_matrix
				if $self->quality_size > $prev_len;
		} else {
			croak "Different length at " . $self->quality_matrix
				if $prev_len != $act_len;
		}

		my @quality = split //;
		for (my $i = 0; $i <= $#quality; $i++) {
			$freq[$i]{$quality[$i]} ++;
		}
	}
	
	close $fh;
	return \@freq;
}

sub _get_weight {
	my ($self, $freq) = @_;
	my @pos = map {$self->calculate_weight($_)} @$freq;
	return \@pos;
}

sub gen_quality {
	my $self = shift;
	my @q;
	
	for (my $i = 0; $i < $self->quality_size; $i++) {
		push @q => $self->weighted_raffle($self->_pos->[$i]);
	}

	return join "" => @q;
}

__PACKAGE__->meta->make_immutable;

1;
