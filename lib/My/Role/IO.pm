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
 
1;
