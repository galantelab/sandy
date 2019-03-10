package App::Sandy::Role::Template::Fastq;
# ABSTRACT: Fastq template role

use App::Sandy::Base 'role';

our $VERSION = '0.23'; # VERSION

sub with_fastq_template {
	my ($self, $seqid_ref, $read_ref, $quality_ref) = @_;
	my $fastq = "\@$$seqid_ref\n$$read_ref\n+\n$$quality_ref\n";
	return \$fastq;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::Template::Fastq - Fastq template role

=head1 VERSION

version 0.23

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

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
