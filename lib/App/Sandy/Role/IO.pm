package App::Sandy::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::Sandy::Base 'role';
use App::Sandy::BGZF;
use IO::Compress::Gzip '$GzipError';
use PerlIO::gzip;

our $VERSION = '0.23'; # VERSION

sub with_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or die "Not possible to read $file: $!\n";

	return $fh;
}

sub with_open_w {
	my ($self, $file, $level) = @_;

	my $fh;

	if ($level) {
		$fh = IO::Compress::Gzip->new($file, -Level => $level)
			or die "Not possible to create $file: $GzipError\n";
	} else {
		open $fh, '>' => $file
			or die "Not possible to create $file: $!\n";
	}

	return $fh;
}

sub with_open_a {
	my ($self, $file) = @_;

	open my $fh, '>>' => $file
		or die "Not possible to append to $file: $!\n";

	return $fh;
}

sub with_open_bam_w {
	my ($self, $file, $level) = @_;
	my $fh = App::Sandy::BGZF->new_filehandle($file, $level);
	return $fh;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::IO - Input and output custom wrappers.

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
