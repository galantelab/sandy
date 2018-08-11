package App::Sandy::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::Sandy::Base 'role';
use PerlIO::gzip;
use Compress::BGZF::Writer;

sub with_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or die "Not possible to read $file: $!\n";

	return $fh;
}

sub with_open_w {
	my ($self, $file, $is_gzipped) = @_;

	my $fh;
	my $mode;

	if ($is_gzipped) {
		$mode = ">:gzip";
	} else {
		$mode = ">";
	}

	open $fh, $mode => $file
		or die "Not possible to create $file: $!\n";

	return $fh;
}

sub with_open_bam_w {
	my ($self, $file) = @_;

	my $fh = Compress::BGZF::Writer->new_filehandle($file)
		or die "Not possible to create $file: $!\n";

	return $fh;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::IO - Input and output custom wrappers.

=head1 VERSION

version 0.19

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

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
