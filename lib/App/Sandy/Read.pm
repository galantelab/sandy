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

	my $attr = {
		'start'     => $pos + 1,
		'end'       => $pos + $len,
		'start_ref' => $pieces->[0]{is_orig} ? $pieces->[0]{pos} + $offset + 1 : 'NA',
		'end_ref'   => $pieces->[-1]{is_orig} ? $pieces->[0]{pos} + $offset + $len : 'NA',
		'annot'     => \@annot
	};

	return (\$read, $attr);
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
		push @errors => sprintf("%d:%s/%s", $pos + 1, $b, $not_b);
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
