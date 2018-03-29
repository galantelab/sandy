package App::SimulateReads::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::SimulateReads::Base 'role';
use PerlIO::gzip;

our $VERSION = '0.14'; # VERSION

sub my_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or croak "Not possible to read $file: $!";

	return $fh;
}

sub my_open_w {
	my ($self, $file, $is_gzipped) = @_;

	my $fh;
	my $mode;

	if ($is_gzipped) {
		$mode = ">:gzip";
	} else {
		$mode = ">";
	}

	open $fh, $mode => $file
		or croak "Not possible to create $file: $!";

	return $fh;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Role::IO - Input and output custom wrappers.

=head1 VERSION

version 0.14

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
