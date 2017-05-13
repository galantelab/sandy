#
#===============================================================================
#
#         FILE: PairedEnd.pm
#
#  DESCRIPTION: Fastq::PairedEnd class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 05:06:32 PM
#     REVISION: ---
#===============================================================================

package Fastq::PairedEnd;

use Moose;
use Carp;
use Read::PairedEnd;
use namespace::autoclean;

extends 'Fastq';

has 'fragment_mean'    => (is => 'rw', isa => 'Int', required => 1);
has 'fragment_stdd'    => (is => 'rw', isa => 'Int', required => 1);
has 'sequencing_error' => (is => 'ro', isa => 'Num', required => 1);
has 'read'             => (
	is         => 'ro',
	isa        => 'Read::PairedEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub _build_read {
	my $self = shift;
	Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);
}

override 'fastq' => sub {
	my ($self, $id, $seq_name, $seq, $seq_size, $is_leader) = @_;

	my ($read1, $read2, $fragment_pos, $fragment_size) = $self->gen_read($seq, $seq_size, $is_leader);

	my ($seq_pos1, $seq_pos2) = (
		"$seq_name:" . ($fragment_pos + 1) . "-" . ($fragment_pos + $self->read_size),
		"$seq_name:" . ($fragment_pos + $fragment_size) . "-" . ($fragment_pos + $fragment_size - $self->read_size + 1)
	);

	unless ($is_leader) {
		($seq_pos1, $seq_pos2) = ($seq_pos2, $seq_pos1);
	}

	my $header1 = "$id 1 Simulation_read sequence_position=$seq_pos1";
	my $header2 = "$id 2 Simulation_read sequence_position=$seq_pos2";

	my $fastq = super($header1, \$read1);
	$fastq .= "\n";
	$fastq .= super($header2, \$read2);

	return $fastq;
};

__PACKAGE__->meta->make_immutable;

1;
