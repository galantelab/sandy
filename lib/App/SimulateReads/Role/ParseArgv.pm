package App::SimulateReads::Role::ParseArgv;
# ABSTRACT: Getopt::Long wrapper.

use App::SimulateReads::Base 'role';
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
