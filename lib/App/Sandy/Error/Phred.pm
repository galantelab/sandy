package App::Sandy::Error::Phred;
# ABSTRACT: Calculate error based on the phred score

use App::Sandy::Base 'class';

use constant ASCII_INIT => 0x21;

extends 'App::Sandy::Error';

# VERSION

sub insert_sequencing_error {
	my ($self, $read_ref, $quality_ref, $read_size, $rng) = @_;
	my @errors;

	for (my $i = 0; $i < $read_size; $i++) {
		my $char = substr $$quality_ref, $i, 1;

		if ($self->_is_there_any_error($char, $rng)) {
			my $base = substr $$read_ref, $i, 1;
			my $not_base = $self->randb($base, $rng);

			substr($$read_ref, $i, 1) = $not_base;

			push @errors => sprintf("%d:%s/%s", $i + 1, $base, $not_base);
		}
	}

	return \@errors;
}

sub _is_there_any_error {
	my ($self, $char, $rng) = @_;
	my $score = ord($char) - ASCII_INIT;
	my $prob = 10 ** (-$score / 10);
	return int($rng->uniform() * (1 / $prob)) == 0;
}
