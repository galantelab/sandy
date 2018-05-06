package App::Sandy::Fastq;
# ABSTRACT: Base class to simulate fastq entries

use App::Sandy::Base 'class';
use App::Sandy::Quality;

our $VERSION = '0.18'; # VERSION

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
	isa        => 'App::Sandy::Quality',
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
	App::Sandy::Quality->new(
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

App::Sandy::Fastq - Base class to simulate fastq entries

=head1 VERSION

version 0.18

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
