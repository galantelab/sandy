#
#===============================================================================
#
#         FILE: Read.pm
#
#  DESCRIPTION: 'Read' base class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/29/2017 09:23:35 PM
#     REVISION: ---
#===============================================================================

package Read;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Params::Validate;
use My::Types;
use Carp 'croak';

use namespace::autoclean;

has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS',  required => 1);
has 'read_size'        => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_count_base'      => (is => 'rw', isa => 'Int',       default  => 0);
has '_base'            => (is => 'rw', isa => 'Int');

sub BUILD {
	my $self = shift;

	#If sequencing_error equal to zero, set _base to zero
	$self->_base($self->sequencing_error ? int(1 / $self->sequencing_error) : 0);
}

before 'subseq' => sub {
	my $self = shift;
	my ($seq, $seq_len, $slice_len, $pos) = pos_validated_list(
		\@_,
		{ isa => 'ScalarRef[Str]' },
		{ isa => 'My:IntGt0'      },
		{ isa => 'My:IntGt0'      },
		{ isa => 'My:IntGe0'      }
	);

	croak "slice_len ($slice_len) greater than seq_len ($seq_len)"
		unless $slice_len <= $seq_len;

	croak "slice_len + pos <= seq_len ($slice_len + $pos) <= $seq_len"
		unless ($slice_len + $pos) <= $seq_len;
};

sub subseq {
	my ($self, $seq, $seq_len, $slice_len, $pos) = @_;
	
	my $read = substr $$seq, $pos, $slice_len;
	return $read;
}

before 'subseq_rand' => sub {
	my $self = shift;
	my ($seq, $seq_len, $slice_len) = pos_validated_list(
		\@_,
		{ isa => 'ScalarRef[Str]' },
		{ isa => 'My:IntGt0'      },
		{ isa => 'My:IntGt0'      }
	);

	croak "slice_len ($slice_len) greater than seq_len ($seq_len)"
		unless $slice_len <= $seq_len;
};

sub subseq_rand {
	my ($self, $seq, $seq_len, $slice_len) = @_;

	my $usable_len = $seq_len - $slice_len;
	my $pos = $self->_randp($usable_len);
	my $read = substr $$seq, $pos, $slice_len;
	return ($read, $pos);
}

before 'insert_sequencing_error' => sub {
	my $self = shift;
	my ($seq_ref) = pos_validated_list(
		\@_,
		{ isa => 'ScalarRef[Str]' }
	);
};

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

before 'update_count_base' => sub {
	my $self = shift;
	my ($val) = pos_validated_list(
		\@_,
		{ isa => 'Int' }
	);
};

sub update_count_base {
	my ($self, $val) = @_;
	$self->_count_base($self->_count_base + $val);
}

before 'reverse_complement' => sub {
	my $self = shift;
	my ($seq) = pos_validated_list(
		\@_,
		{ isa => 'ScalarRef[Str]' }
	);
};

sub reverse_complement {
	my ($self, $seq) = @_;
	$$seq = reverse $$seq;
	$$seq =~ tr/atcgATCG/tagcTAGC/;
}

sub _randb {
	my ($self, $not_b) = @_;
	my $b = $not_b;
	$b = qw{A T C G}[int(rand(4))] while $b eq $not_b;
	return $b;
}

sub _randp {
	my ($self, $len) = @_;
	return int(rand($len + 1));
}

__PACKAGE__->meta->make_immutable;

1;
