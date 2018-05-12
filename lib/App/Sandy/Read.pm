package App::Sandy::Read;
# ABSTRACT: Base class to simulate reads

use App::Sandy::Base 'class';

# VERSION

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has 'read_size' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
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
	my ($self, $seq_ref, $seq_len, $slice_len) = @_;
	my $usable_len = $seq_len - $slice_len;
	my $pos = int(rand($usable_len + 1));
	my $read = substr $$seq_ref, $pos, $slice_len;
	return (\$read, $pos);
}

sub subseq_rand_ptable {
	my ($self, $ptable, $ptable_size, $slice_len) = @_;
	my $usable_len = $ptable_size - $slice_len;
	my $pos = int(rand($usable_len + 1));
	my $pieces = $ptable->lookup($pos, $slice_len);
	return $self->_build_subseq($pieces, $pos, $slice_len);
}

sub _build_subseq {
	my ($self, $pieces, $pos, $len) = @_;

	my $offset = $pos - $pieces->[0]{offset};
	my $usable_len = $pieces->[0]{len} - $offset;

	# TODO: 'pos_rel' -> if the strand is minus, then
	# pos_rel = read_size - (pos_rel+1), else
	# pos_rel = pos_rel + 1
	my @annot;

	if (not $pieces->[0]{is_orig}) {
		push @annot => {
			pos     => $pieces->[0]{pos},
			offset  => $pieces->[0]{offset},
			pos_rel => 0,
			annot   => $pieces->[0]{annot}
		};
	}

	my $slice_len = $len < $usable_len
		? $len
		: $usable_len;

	my $read = substr ${ $pieces->[0]{ref} }, $pieces->[0]{start} + $offset, $slice_len;
	my $miss_len = $len - $slice_len;

	for (my $i = 1; $i < @$pieces; $i++) {

		if (defined $pieces->[$i]{annot}) {
			my $pos = $pieces->[$i]{is_orig}
				? $pieces->[$i - 1]{pos} + $pieces->[$i - 1]{len}
				: $pieces->[$i]{pos};

			push @annot => {
				pos     => $pos,
				offset  => $pieces->[$i]{offset},
				pos_rel => length $read,
				annot   => $pieces->[$i]{annot}
			};
		}

		$slice_len = $miss_len < $pieces->[$i]{len}
			? $miss_len
			: $pieces->[$i]{len};

		$read .= substr ${ $pieces->[$i]{ref} }, $pieces->[$i]{start}, $slice_len;
		$miss_len -= $slice_len;
	}

	return (\$read, $pos, \@annot);
}

sub insert_sequencing_error {
	my ($self, $seq_ref) = @_;

	my $err = int($self->_count_base * $self->sequencing_error);
	my @errors;

	for (my $i = 0; $i < $err; $i++) {
		$self->update_count_base(-$self->_base);
		my $pos = $self->read_size - $self->_count_base - 1;

		my $b = substr($$seq_ref, $pos, 1);
		my $not_b = $self->_randb($b);

		substr($$seq_ref, $pos, 1) = $not_b;
		push @errors => { b => $b, not_b => $not_b, pos => $pos };
	}

	return \@errors;
}

sub update_count_base {
	my ($self, $val) = @_;
	$self->_count_base($self->_count_base + $val);
}

sub reverse_complement {
	my ($self, $seq_ref) = @_;
	$$seq_ref = reverse $$seq_ref;
	$$seq_ref =~ tr/atcgATCG/tagcTAGC/;
}

sub _randb {
	my ($self, $base) = @_;
	return $self->_not_base->{$base}[int(rand(3))] || $base;
}