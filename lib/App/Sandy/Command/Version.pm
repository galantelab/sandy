package App::Sandy::Command::Version;
# ABSTRACT: version command class. Print version

use App::Sandy::Base 'class';
use Pod::Usage;

extends 'App::Sandy::CLI::Command';

# VERSION

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	pod2usage(-verbose => 99, -sections => ['NAME', 'VERSION', 'AUTHOR', 'COPYRIGHT AND LICENSE'], -exitval => 0);
}
