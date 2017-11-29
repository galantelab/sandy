package App::SimulateReads::Fastq::PairedEnd;
# ABSTRACT: App::SimulateReads::Fastq subclass for simulate paired-end fastq entries.

use App::SimulateReads::Base 'class';
use App::SimulateReads::Read::PairedEnd;

extends 'App::SimulateReads::Fastq';

our $VERSION = '0.09'; # VERSION

has 'fragment_mean' => (
	is         => 'rw',
	isa        => 'My:IntGt0',
	required   => 1
);

has 'fragment_stdd' => (
	is         => 'rw',
	isa        => 'My:IntGe0',
	required   => 1
);

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has '_read' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Read::PairedEnd',
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
	App::SimulateReads::Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);
}

sub sprint_fastq {
	my ($self, $id, $seq_name, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read1_ref, $read2_ref, $fragment_pos, $fragment_size) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my ($seq_pos1, $seq_pos2) = (
		"$seq_name:" . ($fragment_pos + 1) . "-" . ($fragment_pos + $self->read_size),
		"$seq_name:" . ($fragment_pos + $fragment_size) . "-" . ($fragment_pos + $fragment_size - $self->read_size + 1)
	);

	unless ($is_leader) {
		($seq_pos1, $seq_pos2) = ($seq_pos2, $seq_pos1);
	}

	my $header1 = "$id simulation_read length=" . $self->read_size . " position=$seq_pos1";
	my $header2 = "$id simulation_read length=" . $self->read_size . " position=$seq_pos2";

	my $fastq1_ref = $self->fastq_template(\$header1, $read1_ref);
	my $fastq2_ref = $self->fastq_template(\$header2, $read2_ref);

	return ($fastq1_ref, $fastq2_ref);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Fastq::PairedEnd - App::SimulateReads::Fastq subclass for simulate paired-end fastq entries.

=head1 VERSION

version 0.09

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
