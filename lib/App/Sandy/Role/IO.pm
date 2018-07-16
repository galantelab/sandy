package App::Sandy::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::Sandy::Base 'role';
use PerlIO::gzip;
use Compress::BGZF::Writer;

# VERSION

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
