package App::Sandy::BGZF;
# ABSTRACT: Wrapper around Compress::BGZF::Writer in order
# to enable compression-level option

use App::Sandy::Base 'class';
use Compress::BGZF::Writer;

# VERSION

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
