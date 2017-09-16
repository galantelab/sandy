package App::SimulateReads::Role::IO;
# ABSTRACT: Input and output custom wrappers.

use App::SimulateReads::Base 'role';
use PerlIO::gzip;
use Scalar::Util 'looks_like_number';

# VERSION

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
	} else {
		$mode = ">";
	}

	open $fh, $mode => $file
		or croak "Not possible to create $file: $!";

	return $fh;
} ## --- end sub my_open_w
 
#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::IO (Role)
#       METHOD: index_fasta
#   PARAMETERS: $fasta My:Fasta
#      RETURNS: HashRef[Hashref]
#  DESCRIPTION: Indexes a fasta file: id => (seq, size)
#       THROWS: It tries to validate the fasta file, if fails, throws an error
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub index_fasta {
	my ($self, $fasta) = @_;
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
			$id = uc $id;
		} else {
			croak "Error reading fasta file '$fasta': Not defined id"
				unless defined $id;
			$indexed_fasta{$id}{seq} .= $_;
		}
	}
	
	for (keys %indexed_fasta) {
		$indexed_fasta{$_}{size} = length $indexed_fasta{$_}{seq};
	}

	$fh->close
		or croak "Cannot close file $fasta: $!\n";

	return \%indexed_fasta;
} ## --- end sub index_fasta

#===  CLASS METHOD  ============================================================
#        CLASS: My::Role::IO
#       METHOD: index_weight_file
#   PARAMETERS: $weight_file My:File
#      RETURNS: $indexed_file Hashref[Int]
#  DESCRIPTION: It indexes a tab separated file with a seqid and its weight
#       THROWS: It tries to validate the file, if fails, the throws an exception
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub index_weight_file {
	my ($self, $weight_file) = @_;
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
		croak "Error parsing '$weight_file': weight (second column) does not look like a number at line $line\n" if not looks_like_number($fields[1]);
		croak "Error parsing '$weight_file': weight (second column) lesser or equal to zero at line $line\n" if $fields[1] <= 0;
		$indexed_file{uc $fields[0]} = $fields[1];
	}
	
	$fh->close
		or croak "Cannot close file $weight_file: $!\n";

	return \%indexed_file;
} ## --- end sub index_weight_file
