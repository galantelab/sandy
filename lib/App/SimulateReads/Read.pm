package App::SimulateReads::Read;
# ABSTRACT: Base class to simulate reads

use App::SimulateReads::Base 'class';

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

sub insert_sequencing_error {
	my ($self, $seq_ref) = @_;
	my $err = int($self->_count_base * $self->sequencing_error);

	for (my $i = 0; $i < $err; $i++) {
		$self->update_count_base(-$self->_base);
		my $pos = $self->read_size - $self->_count_base - 1;
		my $b = substr($$seq_ref, $pos, 1);
		substr($$seq_ref, $pos, 1) = $self->_randb($b);
	}
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
