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
use MooseX::Params::Validate;
use My::Types;
use PerlIO::gzip;
use Carp 'croak';

before 'my_open_r' => sub {
	my $self = shift;
	my ($file) = pos_validated_list(
		\@_,
		{ isa => 'My:File' }
	);
};

sub my_open_r {
	my ($self, $file) = @_;

	my $fh;
	my $mode = $file =~ /\.gz$/ ? "<:gzip" : "<";

	open $fh, $mode => $file
		or croak "Not possible to read $file: $!";

	return $fh;
}

before 'my_open_w' => sub {
	my $self = shift;
	my ($file, $is_gzipped) = pos_validated_list(
		\@_,
		{ isa => 'Str'  },
		{ isa => 'Bool' }
	);

};

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
}
 
before 'index_fasta' => sub {
	my $self = shift;
	my ($fasta) = pos_validated_list(
		\@_,
		{ isa => 'My:Fasta' }
	);
};

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

1;
