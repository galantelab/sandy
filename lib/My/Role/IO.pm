#
#===============================================================================
#
#         FILE: IO.pm
#
#  DESCRIPTION: Input and output custom wrappers
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 20-05-2017 18:25:44
#     REVISION: ---
#===============================================================================

package My::Role::IO;

use Moose::Role;
use PerlIO::gzip;
use Carp 'croak';

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::IO (Role)
#       METHOD: my_open_r
#   PARAMETERS: $file File
#      RETURNS: $fh IO::File
#  DESCRIPTION: Verify if the file is gzipped compressed and open it properly
#       THROWS: If open fails, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub my_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or croak "Not possible to read $file: $!";

	return $fh;
} ## --- end sub my_open_r

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::IO (Role)
#       METHOD: my_open_w
#   PARAMETERS: $file Str, $is_gzipped Bool
#      RETURNS: $fh IO::File
#  DESCRIPTION: Opens for writing a file, gzipped or not
#       THROWS: If open fails, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub my_open_w {
	my ($self, $file, $is_gzipped) = @_;

	my $fh;
	my $mode;

	if ($is_gzipped) {
		$mode = ">:gzip";
		$file .= '.gz';
	} else {
		$mode = ">";
	}

	open $fh, $mode => $file
		or croak "Not possible to create $file: $!";

	return $fh;
} ## --- end sub my_open_w
 
sub index_fasta {
	my ($self, $fasta) = @_;
	print STDERR "file: $fasta\n";
	my $fh = $self->my_open_r($fasta);

	# indexed_genome = ID => (seq, len)
	my %indexed_fasta;
	my $id;
	while (<$fh>) {
		chomp;
		next if /^;/;
		if (/^>/) {
			my @fields = split /\|/;
			$id = (split / / => $fields[0])[0];
			$id =~ s/^>//;
		} else {
			croak "Error reading fasta file '$fasta': Not defined id"
				unless defined $id;
			$indexed_fasta{$id}{seq} .= $_;
		}
	}
	
	for (keys %indexed_fasta) {
		$indexed_fasta{$_}{size} = length $indexed_fasta{$_}{seq};
	}

	$fh->close;
	return \%indexed_fasta;
}

sub index_weight_file {
	my ($self, $weight_file) = @_;
	print STDERR "file: $weight_file\n";
	my $fh = $self->my_open_r($weight_file);
	my %indexed_file;
	my $line = 0;
	while (<$fh>) {
		$line++;
		chomp;
		next if /^\s*$/;
		my @fields = split /\t/;
		croak "Error parsing '$weight_file': seqid (first column) not found at line $line\n" unless defined $fields[0];
		croak "Error parsing '$weight_file': weight (second column) not found at line $line\n" unless defined $fields[1];
		$indexed_file{$fields[0]} = $fields[1];
	}
	
	$fh->close;
	return \%indexed_file;
}

1; ## --- end class My::Role::IO
