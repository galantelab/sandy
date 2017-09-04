#
#===============================================================================
#
#         FILE: ParseArgv.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 03-09-2017 22:38:31
#     REVISION: ---
#===============================================================================

package My::Role::ParseArgv;

use My::Base 'role';
use Getopt::Long 'GetOptionsFromArray';

sub parser {
	my ($self, $argv, @opt_spec) = @_;
	my @argv = @{ $argv };
	my %opts;

	Getopt::Long::Configure('gnu_getopt');

	GetOptionsFromArray(
		\@argv,
		\%opts,
		@opt_spec
	) or die "Error parsing command-line arguments\n";
	
	return (\%opts, \@argv);
}
