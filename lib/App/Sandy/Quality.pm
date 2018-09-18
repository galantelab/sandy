package App::Sandy::Quality;
# ABSTRACT: Class to simulate quality entries

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Quality;

with 'App::Sandy::Role::Counter';

our $VERSION = '0.21'; # VERSION

has 'quality_profile' => (
	is         => 'ro',
	isa        => 'My:QualityP',
	required   => 1,
	coerce     => 1
);

has '_quality_by_system' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'My:QualityH',
	builder    => '_build_quality_by_system',
	lazy_build => 1,
	handles    => {
		_get_quality_by_system => 'get'
	}
);

has '_gen_quality' => (
	traits     => ['Code'],
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_gen_quality',
	lazy_build => 1,
	handles    => {
		gen_quality => 'execute'
	}
);

has '_phred_score' => (
	traits     => ['Array'],
	isa        => 'ro',
	isa        => 'ArrayRef',
	builder    => '_build_phred_score',
	handles    => {
		_count_phred_score => 'count',
		_get_phred_score   => 'get'
	}
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_quality_by_system if $self->quality_profile ne 'poisson';
}

sub _build_gen_quality {
	my $self = shift;
	my $fun;

	if ($self->quality_profile eq 'poisson') {
		$fun = sub { $self->_gen_quality_by_poisson_dist(@_) };
	} else {
		$fun = sub { $self->_gen_quality_by_system(@_) };
	}

	return $fun;
}

sub _build_phred_score {
	my $self = shift;

	my @phred_score = (
		{
			score  => ['I', 'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A', '@', '?'],
			size   => 11,
			ratio  => 1.5
		},
		{
			score  => ['>', '=', '<', ';', ':', '9', '8', '7', '6', '5'],
			size   => 10,
			ratio  => 2
		},
		{
			score  => ['4', '3', '2', '1', '0', '/', '.', '-', ',', '+'],
			size   => 10,
			ratio  => 2
		},
		{
			score  => ['*', ')', '(', '\'', '&', '%', '$', '#', '"', '!'],
			size   => 10,
			ratio  => 1
		}
	);

	return \@phred_score;
}

sub _build_quality_by_system {
	my $self = shift;
	my $db = App::Sandy::DB::Handle::Quality->new;
	my ($matrix, $deepth, $partil) = $db->retrievedb($self->quality_profile);
	return {
		matrix => $matrix,
		deepth => $deepth,
		partil => $partil
	};
}

sub _gen_quality_by_system {
	my ($self, $read_size) = @_;

	my ($matrix, $deepth, $partil) = $self->_get_quality_by_system(
		qw/matrix deepth partil/
	);

	my ($bin, $left);

	# To make this routine more robust.
	# It is necessary to work on reads
	# lesser than read_size
	if ($read_size < $partil) {
		$partil = $read_size;
		$bin = 1;
		$left = 0;
	} else {
		$bin = int($read_size / $partil);
		$left = $read_size % $partil;
	}

	my $pick_again = $self->with_make_counter($read_size - $left, $left);
	my $quality;

	for (my $i = 0; $i < $partil; $i++) {
		for (my $j = 0; $j < $bin; $j++) {
			$quality .= $matrix->[$i][int(rand($deepth))];
			if ($pick_again->()) {
				$quality .= $matrix->[$i][int(rand($deepth))];
			}
		}
	}

	return \$quality;
}

sub _gen_quality_by_poisson_dist {
	my ($self, $read_size) = @_;
	my $quality;
	return $self->_poisson_dist(\$quality, $read_size, $self->_count_phred_score);
}

sub _poisson_dist {
	my ($self, $quality_ref, $size, $countdown) = @_;
	return $quality_ref if not $countdown;

	my $phred_score = $self->_get_phred_score($self->_count_phred_score - $countdown);
	my $part = int($size / $phred_score->{ratio}) + ($size % $phred_score->{ratio});

	for (my $i = 0; $i < $part; $i++) {
		$$quality_ref .= $phred_score->{score}[int(rand($phred_score->{size}))];
	}

	return $self->_poisson_dist($quality_ref, $size - $part, $countdown - 1);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Quality - Class to simulate quality entries

=head1 VERSION

version 0.21

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
