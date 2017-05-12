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
#					quality_size       => 76
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
use Carp 'croak';
use namespace::autoclean;

with 'Role::WeightedRaffle';

has 'quality_matrix'    => (is => 'ro', isa => 'Str',      required => 1);
has 'quality_size'      => (is => 'rw', isa => 'Int',      required => 1);
has '_max_quality_size' => (is => 'rw', isa => 'Int');
has '_pos'              => (is => 'rw', isa => 'ArrayRef');

sub BUILD {
	my $self = shift;

	my $freq = $self->_get_freq;
	$self->_get_weight($freq);
}

before 'quality_size' => sub {
	my ($self, $quality_size) = @_;
	if (defined $quality_size) {
		croak "Read lenght $quality_size is grater than the max read size: " . $self->_max_quality_size
			if $quality_size > $self->_max_quality_size;
	}
};

sub _get_freq {
	my $self = shift;

	my $fh;
	if ($self->quality_matrix =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->quality_matrix
			or croak "Not possible to open pipe to " . $self->quality_matrix . ": $!";
	} else {
		open $fh, "<" => $self->quality_matrix
			or croak "Not possible to read " . $self->quality_matrix . ": $!";
	}

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
			$self->_max_quality_size($prev_len);
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
	my @pos = map {$self->_calculate_weight($_)} @$freq;
	$self->_pos(\@pos);
}

sub debug {
	my $self = shift;
	require Data::Dumper;
	print Dumper($self->_pos);
}

sub gen_quality {
	my $self = shift;
	my @q;
	
	for (my $i = 0; $i < $self->quality_size; $i++) {
		push @q => $self->_gen_quality($i);
	}

	return join "" => @q;
}

sub _gen_quality {
	my ($self, $pos) = @_;
	my $pos_weight = $self->_pos->[$pos];

	my $range = int(rand($pos_weight->{acm} + 1));
	my $weights = $pos_weight->{weight};

	return $self->_search($weights, 0, $#{$weights}, $range);
}

__PACKAGE__->meta->make_immutable;

1;
