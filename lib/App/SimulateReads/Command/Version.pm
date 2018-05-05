package App::SimulateReads::Command::Version;
# ABSTRACT: version command class. Print version

use App::SimulateReads::Base 'class';
use Pod::Usage;

extends 'App::SimulateReads::CLI::Command';

# VERSION

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	pod2usage(-verbose => 99, -sections => ['NAME', 'VERSION', 'AUTHOR', 'COPYRIGHT AND LICENSE'], -exitval => 0);
}

__END__
