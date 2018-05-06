package App::Sandy::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::Sandy::Base 'role';
use PerlIO::gzip;

# VERSION

sub with_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or die "Not possible to read $file: $!";

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
		or die "Not possible to create $file: $!";

	return $fh;
}
