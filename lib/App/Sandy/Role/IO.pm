package App::Sandy::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::Sandy::Base 'role';
use App::Sandy::BGZF;
use IO::Compress::Gzip '$GzipError';
use PerlIO::gzip;

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
