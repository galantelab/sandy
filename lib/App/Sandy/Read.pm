package App::Sandy::Read;
# ABSTRACT: Base class to simulate reads

use App::Sandy::Base 'class';
use List::Util 'first';

use constant NUM_TRIES => 1000;

with 'App::Sandy::Role::BSearch';

our $VERSION = '0.25'; # VERSION

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has '_count_base' => (
	is         => 'rw',
	isa        => 'Int',
	default    => 0
);

has '_base' => (
	is         => 'rw',
	isa        => 'Int',
	builder    => '_build_base',
	lazy_build => 1
);

has '_not_base' => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_not_base',
	lazy_build => 1
);

sub _build_not_base {
	my %not_base = (
		A => ['T', 'C', 'G'],
		a => ['t', 'c', 'g'],
		T => ['A', 'C', 'G'],
		t => ['a', 'c', 'g'],
		C => ['A', 'T', 'G'],
		c => ['a', 't', 'g'],
		G => ['A', 'T', 'C'],
		g => ['a', 't', 'c']
	);
	return \%not_base;
}

sub _build_base {
	my $self = shift;
	# If sequencing_error equal to zero, set _base to zero
	return $self->sequencing_error && int(1 / $self->sequencing_error);
}

sub subseq {
	my ($self, $seq_ref, $seq_len, $slice_len, $pos) = @_;
	my $read = substr $$seq_ref, $pos, $slice_len;
	return \$read;
}

sub subseq_rand {
	my ($self, $seq_ref, $seq_len, $slice_len, $rng) = @_;
	my $usable_len = $seq_len - $slice_len;
	# Use App::Sandy::Rand
	my $pos = $rng->get_n($usable_len + 1);
	my $read = substr $$seq_ref, $pos, $slice_len;
	return (\$read, $pos);
}

sub subseq_rand_ptable {
	my ($self, $ptable, $ptable_size, $slice_len, $sub_slice_len, $rng, $blacklist) = @_;
	my $usable_len = $ptable_size - $slice_len;

	state $cmp_func = sub {
		my ($key1, $key2) = @_;
		if ($key1->[1] >= $key2->[0] && $key1->[0] <= $key2->[1]) {
			return 0;
		}
		elsif ($key1->[0] > $key2->[0]) {
			return 1;
		} else {
			return -1;
		}
	};

	my $is_inside_blacklist;
	my $pos = 0;
	my $random_tries = 0;

	do {
		if (++$random_tries > NUM_TRIES) {
			croak sprintf
				"Too many tries to calculate a valid random position\n" .
				"Your FASTA file may be full of NNN regions\n"
		}

		# Use App::Sandy::Rand
		$pos = $rng->get_n($usable_len + 1);

		$is_inside_blacklist = $self->with_bsearch([$pos, $pos + $slice_len - 1],
			$blacklist, scalar @$blacklist, $cmp_func);

	} while (defined $is_inside_blacklist);

	my $pieces = $ptable->lookup($pos, $slice_len);
	return $self->_build_subseq($pieces, $pos, $slice_len, $sub_slice_len);
}

sub _build_subseq {
	my ($self, $pieces, $pos, $len, $sub_len) = @_;

	my $offset = $pos - $pieces->[0]{offset};
	my $usable_len = $pieces->[0]{len} - $offset;

	my @annot;

	if (not $pieces->[0]{is_orig}) {
		push @annot => @{ $pieces->[0]{annot2} } if @{ $pieces->[0]{annot2} };
		push @annot => $pieces->[0]{annot1} if $pieces->[0]{annot1};
	}

	my $slice_len = $len < $usable_len
		? $len
		: $usable_len;

	my $read = substr ${ $pieces->[0]{ref} }, $pieces->[0]{start} + $offset, $slice_len;
	my $miss_len = $len - $slice_len;

	for (my $i = 1; $i < @$pieces; $i++) {

		push @annot => @{ $pieces->[$i]{annot2} } if @{ $pieces->[$i]{annot2} };
		push @annot => $pieces->[$i]{annot1} if $pieces->[$i]{annot1};

		$slice_len = $miss_len < $pieces->[$i]{len}
			? $miss_len
			: $pieces->[$i]{len};

		$read .= substr ${ $pieces->[$i]{ref} }, $pieces->[$i]{start}, $slice_len;
		$miss_len -= $slice_len;
	}

	# I must to make this mess in order to annotate paired-end reads :(
	my $start_ref = $pieces->[0]{pos} + $offset;
	my $end_ref = $start_ref + $len - 1;
	my $read_end_ref = $start_ref + $sub_len - 1;
	my $read_end_piece = first { $self->_is_pos_inside_piece($read_end_ref, $_) } reverse @$pieces;
	my $read_start_ref = $end_ref - $sub_len + 1;
	my $read_start_piece = first { $self->_is_pos_inside_piece($read_start_ref, $_) } @$pieces;

	my $attr = {
		'start'          => $pos + 1,
		'end'            => $pos + $len,
		'start_ref'      => $pieces->[0]{is_orig} ? $start_ref + 1 : 'NA',
		'end_ref'        => $pieces->[-1]{is_orig} ? $end_ref + 1 : 'NA',
		'read_end_ref'   => $read_end_piece->{is_orig} ? $read_end_ref + 1 : 'NA',
		'read_start_ref' => $read_start_piece->{is_orig} ? $read_start_ref + 1 : 'NA',
		'annot'          => \@annot
	};

	return (\$read, $attr);
}

sub _is_pos_inside_piece {
	my ($self, $pos, $piece) = @_;
	my $end = $piece->{pos} + $piece->{len} - 1;
	return $pos >= $piece->{pos} && $pos <= $end;
}

sub insert_sequencing_error {
	my ($self, $seq_ref, $read_size, $rng) = @_;
	my @errors;

	if ($self->sequencing_error) {
		my $acm_base = $read_size + $self->_count_base;
		my $num_err = int($acm_base / $self->_base);
		my $left_count = $acm_base % $self->_base;

		for (my $i = 0; $i < $num_err; $i++) {
			my $pos = $i * $self->_base + $self->_base - $self->_count_base - 1;
			my $b = substr($$seq_ref, $pos, 1);
			my $not_b = $self->_randb($b, $rng);
			substr($$seq_ref, $pos, 1) = $not_b;
			push @errors => sprintf("%d:%s/%s", $pos + 1, $b, $not_b);
		}

		$self->_count_base($left_count);
	}

	return \@errors;
}

sub reverse_complement {
	my ($self, $seq_ref) = @_;
	$$seq_ref = reverse $$seq_ref;
	$$seq_ref =~ tr/atcgATCG/tagcTAGC/;
}

sub _randb {
	my ($self, $base, $rng) = @_;
	return $self->_not_base->{$base}[$rng->get_n(3)] || $base;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Read - Base class to simulate reads

=head1 VERSION

version 0.25

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

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Rafael Mercuri <rmercuri@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
