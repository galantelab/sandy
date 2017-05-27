#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Read::PairedEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/29/2017 11:58:41 PM
#     REVISION: ---
#===============================================================================

package Read::PairedEnd;

use Moose;
use MooseX::StrictConstructor;
use My::Types;
use Carp 'croak';
use Math::Random 'random_normal';

use namespace::autoclean;

use constant {
	NUM_TRIES => 10
};

extends 'Read';
with    'My::Role::ABC::Read';

has 'fragment_mean' => (is => 'ro', isa => 'My:IntGt0', required => 1);
has 'fragment_stdd' => (is => 'ro', isa => 'My:IntGt0', required => 1);

sub BUILD {
	my $self = shift;

	croak 'fragment_mean must be greater or equal to read_size'
		unless $self->fragment_mean >= $self->read_size;
}

sub gen_read {
	my ($self, $seq, $seq_size, $is_leader) = @_;
	return if $seq_size < $self->read_size;

	my $fragment_size;
	my $random_tries = 0;

	do {
		return if ++$random_tries == NUM_TRIES;
		$fragment_size = $self->_random_half_normal;
	} while ($seq_size < $fragment_size) || ($fragment_size < $self->read_size);

	my ($fragment, $fragment_pos) = $self->subseq_rand($seq, $seq_size, $fragment_size);	

	my $read1 = $self->subseq(\$fragment, $fragment_size, $self->read_size, 0);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read1);

	my $read2 = $self->subseq(\$fragment, $fragment_size, $self->read_size, $fragment_size - $self->read_size);
	$self->reverse_complement(\$read2);
	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error(\$read2);

	return $is_leader ?
		($read1, $read2, $fragment_pos, $fragment_size) :
		($read2, $read1, $fragment_pos, $fragment_size);
}

sub _random_half_normal {
	my $self = shift;
	my $fragment_size = -1;
	$fragment_size = int(random_normal(1, $self->fragment_mean, $self->fragment_stdd))
		while $fragment_size <= 0;
	return $fragment_size;
}

__PACKAGE__->meta->make_immutable;

1;
