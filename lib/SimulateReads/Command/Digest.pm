#
#===============================================================================
#
#         FILE: Digest.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02-09-2017 21:00:07
#     REVISION: ---
#===============================================================================

package SimulateReads::Command::Digest;

use My::Base 'class';

sub opt_spec {
	'help|h',
	'man|M',
	'prefix|p=s',
	'jobs|j=i'
}

sub validate {
	my ($self, $opts, $argv) = @_;
	die "Option 'jobs' needs to be a positive integer, not '$opts->{jobs}'\n"
		if exists $opts->{jobs} and $opts->{jobs} < 0;
}

sub execute {
	my ($self, $opts, $argv) = @_;
	say "Digest";
}
