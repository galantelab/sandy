#
#===============================================================================
#
#         FILE: SingleEnd.pm
#
#  DESCRIPTION: Fastq::SingleEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 04:23:53 PM
#     REVISION: ---
#===============================================================================

package Fastq::SingleEnd;

use Moose;
use MooseX::StrictConstructor;
use My::Types;
use Read::SingleEnd;

use namespace::autoclean;

extends 'Fastq';

has 'sequencing_error' => (is => 'ro', isa => 'My:NumHS', required => 1);
has '_read'            => (
	is         => 'ro',
	isa        => 'Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub _build_read {
	my $self = shift;
	Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size
	);
}

sub fastq {
	my ($self, $id, $seq_name, $seq, $seq_size, $is_leader) = @_;

	my ($read, $pos) = $self->gen_read($seq, $seq_size, $is_leader);

	my $seq_pos = $is_leader ?
		"$seq_name:" . ($pos + 1) . "-" . ($pos + $self->read_size) :
		"$seq_name:" . ($pos + $self->read_size) . "-" . ($pos + 1);

	my $header = "$id Simulation_read sequence_position=$seq_pos";

	return $self->sprint_fastq(\$header, \$read);
}

__PACKAGE__->meta->make_immutable;

1;
