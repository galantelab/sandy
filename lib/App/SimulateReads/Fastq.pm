package App::SimulateReads::Fastq;
# ABSTRACT: Base class to simulate fastq entries

use App::SimulateReads::Base 'class';
use App::SimulateReads::Quality;

our $VERSION = '0.13'; # VERSION

has 'quality_profile' => (
	is         => 'ro',
	isa        => 'My:QualityP',
	required   => 1,
	coerce     => 1
);

has 'read_size' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 1
);

has '_quality' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_quality;
}

sub _build_quality {
	my $self = shift;
	App::SimulateReads::Quality->new(
		quality_profile => $self->quality_profile,
		read_size       => $self->read_size
	);
}

sub fastq_template {
	my ($self, $header_ref, $seq_ref) = @_;
	my $quality_ref = $self->gen_quality;

	my $fastq = "\@$$header_ref\n";
	$fastq .= "$$seq_ref\n";
	$fastq .= "+\n";
	$fastq .= "$$quality_ref";

	return \$fastq;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Fastq - Base class to simulate fastq entries

=head1 VERSION

version 0.13

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
