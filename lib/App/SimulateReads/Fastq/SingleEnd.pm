package App::SimulateReads::Fastq::SingleEnd;
# ABSTRACT: App::SimulateReads::Fastq subclass for simulate single-end fastq entries.

use App::SimulateReads::Base 'class';
use App::SimulateReads::Read::SingleEnd;

extends 'App::SimulateReads::Fastq';

# VERSION

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has '_read' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_read;
}

sub _build_read {
	my $self = shift;
	App::SimulateReads::Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size
	);
}

sub sprint_fastq {
	my ($self, $id, $seq_name, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read_ref, $pos) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my $seq_pos = $is_leader ?
		"$seq_name:" . ($pos + 1) . "-" . ($pos + $self->read_size) :
		"$seq_name:" . ($pos + $self->read_size) . "-" . ($pos + 1);

	my $header = "$id simulation_read length=" . $self->read_size . " position=$seq_pos";

	return $self->fastq_template(\$header, $read_ref);
}
