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
use Moose::Util::TypeConstraints;
use Carp;
use namespace::autoclean;

subtype 'MyInt',
	as 'Int';

coerce 'MyInt',
	from 'Num',
	via { int };

has 'sequencing_error' => (is => 'rw', isa => 'Num',   required => 1);
has 'read_size'        => (is => 'rw', isa => 'Int',   required => 1);
has '_base'            => (is => 'rw', isa => 'MyInt', coerce   => 1);
has '_count_base'      => (is => 'rw', isa => 'Int',   default  => 0);

sub BUILD {
	my $self = shift;
	$self->_base(1 / $self->sequencing_error);
}

around 'sequencing_error' => sub {
	my ($orig, $self, $err) = @_;
	return $self->$orig() unless defined $err;
	$self->_base(1 / $err);
	return $self->$orig($err);
};

around qw{subseq subseq_rand} => sub {
	my ($orig, $self, $seq, $seq_len, $slice_len, $pos) = @_;

	unless (defined $seq) {
		carp "Skipping: No seq passed to 'subseq'";
		return;
	}

	croak "seq argument must be a reference to a SCALAR"
		unless ref $seq eq 'SCALAR';

	croak "seq_len must be greater than 0"
		unless defined $seq_len and $seq_len > 0;

	croak "slice_len must be greater than 0"
		unless defined $slice_len and $slice_len > 0;

	unless ($slice_len <= $seq_len) {
		carp "Skipping: slice_len ($slice_len) greater than seq_len ($seq_len)";
		return;
	}

	return $self->$orig($seq, $seq_len, $slice_len, $pos);
};

sub subseq {
	my ($self, $seq, $seq_len, $slice_len, $pos) = @_;
	
	croak "pos must be greater than 0"
		unless defined $pos and $pos >= 0;

	my $read = substr $$seq, $pos, $slice_len;
	return $read;
}

sub subseq_rand {
	my ($self, $seq, $seq_len, $slice_len) = @_;

	my $usable_len = $seq_len - $slice_len;
	my $pos = $self->_randp($usable_len);
	my $read = substr $$seq, $pos, $slice_len;
	return $read;
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
