package App::Sandy::Role::Statistic;
# ABSTRACT: Basic statistics

use App::Sandy::Base 'role';
use List::Util 'sum';

sub with_mean {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	return sum(@$vet) / scalar(@$vet);
}

sub with_variance {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	my $mean = $self->with_mean($vet);
	my @diff = map { ($_ - $mean) ** 2 } @$vet;

	return $self->with_mean(\@diff);
}

sub with_stddev {
	my ($self, $vet) = @_;

	if (ref $vet ne 'ARRAY') {
		croak "vet is not an array ref";
	}

	return sqrt $self->with_variance($vet);
}
