package App::Sandy::BGZF;
# ABSTRACT: Wrapper around Compress::BGZF::Writer in order
# to enable compression-level option

use App::Sandy::Base 'class';
use Compress::BGZF::Writer;

our $VERSION = '0.23'; # VERSION

sub TIEHANDLE {
	my ($class, $file, $level) = @_;
	my $writer = Compress::BGZF::Writer->new($file);
	$writer->set_level($level);
	return $writer;
}

sub new_filehandle {
	my ($class, $file, $level) = @_;
	open my $fh, "<", undef;
	tie *$fh, $class, $file, $level
		or croak "Failed to tie filehandle: $!";
	return $fh;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::BGZF - Wrapper around Compress::BGZF::Writer in order

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
