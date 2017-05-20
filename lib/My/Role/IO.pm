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
use Carp 'croak';

before 'open' => sub {
	my $self = shift;
	my ($file) = pos_validated_list(
		\@_,
		{ isa => 'My:File' }
	);
};

sub open {
	my ($self, $file) = @_;

	my $fh;
	if ($file =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c $file"
			or croak "Not possible to open pipe to $file: $!";
	} else {
		open $fh, "<" => $file
			or croak "Not possible to read $file: $!";
	}

	return $fh;
}
 
1;
