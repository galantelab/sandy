package App::Sandy::PieceTable;
# ABSTRACT: Implement a piece table data structure class

use App::Sandy::Base 'class';
use App::Sandy::BTree::Interval;
use Scalar::Util 'refaddr';

with 'App::Sandy::Role::BSearch';

# VERSION

has 'orig' => (
	is         => 'ro',
	isa        => 'ScalarRef',
	required   => 1
);

has 'len' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	lazy_build => 1,
	builder    => '_build_len'
);

has 'piece_table' => (
	traits     => ['Array'],
	is         => 'ro',
	isa        => 'ArrayRef',
	lazy_build => 1,
	builder    => '_build_piece_table',
	handles    => {
		_get_piece     => 'get',
		_splice_piece  => 'splice',
		_count_pieces  => 'count'
	}
);

sub _build_len {
	my $self = shift;
	my $orig = $self->orig;
	return length $$orig;
}

sub _build_piece_table {
	my $self = shift;
	my $piece = $self->_piece_new($self->orig, 0, $self->len, 0);
	return [$piece];
}

sub _piece_new {
	my ($self, $ref, $start, $len, $pos) = @_;

	my $piece = {
		'ref'   => $ref,   # reference to sequence
		'start' => $start, # start position at reference
		'len'   => $len,   # length
		'pos'   => $pos    # position at original sequence
	};

	return $piece;
}

sub insert {
	my ($self, $ref, $pos) = @_;

	if ($pos > $self->len) {
		croak sprintf "position (%d) greater than orig length (%d)"
			=> $pos, $self->len;
	}

	# My length
	my $len = length $$ref;

	# Create piece data
	my $new_piece = $self->_piece_new($ref, 0, $len, $pos);

	# Split piece found at position 'pos'.
	# Update old piece, insert piece and return
	# index where to insert to
	my $index = $self->_split_piece($pos);

	# Then insert new_piece
	$self->_splice_piece($index, 0, $new_piece);
}

sub _split_piece {
	my ($self, $pos) = @_;

	# Insert at start position
	if ($pos == 0) {
		return 0;

	# Insert at end position
	} elsif ($pos == $self->len) {
		return $self->_count_pieces;

	# Insert at some middle
	} else {
		# Catch orig index where pos is inside
		my $index = $self->_piece_at($pos);

		# Get piece which will be updated
		my $old_piece = $self->_get_piece($index);

		# Calculate piece end
		my $old_end = $old_piece->{start} + $old_piece->{len} - 1;

		# Calculate the corrected length according to the split
		my $new_len = $pos - $old_piece->{start};

		# Update piece
		$old_piece->{len} = $new_len;

		# Create the second part of the split after the break position
		my $piece = $self->_piece_new($old_piece->{ref}, $pos, $old_end - $pos + 1, $pos);

		# Insert second part after updated piece
		$self->_splice_piece(++$index, 0, $piece);

		# return corrected index that resolves to
		# the position between the breaked piece
		return $index;
	}
}

sub _is_pos_inside_piece {
	my ($self, $pos, $piece) = @_;
	my $end = $piece->{pos} + $piece->{len} - 1;
	return $pos >= $piece->{pos} && $pos <= $end
		? 1
		: 0;
}

sub _piece_at {
	my ($self, $pos) = @_;

	stat $func = sub {
		my ($pos, $piece) = @_;
		if ($self->_is_pos_inside_piece($pos, $piece) {
			return 0;
		} elsif ($pos > $piece->{pos}) {
			return 1;
		} else {
			return -1;
		}
	};

	my $index = $self->with_bsearch($pos, $self->piece_table, $func);
	my $piece = $self->_get_piece($index);

	# If I catched a non original sequence, then it must
	# be afterward
	if (refaddr($piece->{ref}) != refaddr($self->orig)) {
		$piece = $self->_get_piece(++$index);
		unless ($self->_is_pos_inside_piece($piece, $pos)) {
			croak "Bug: position is not inside the sequence after non original sequence";
		}
	}

	return $index;
}
