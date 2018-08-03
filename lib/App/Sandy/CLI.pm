package App::Sandy::CLI;
# ABSTRACT: Base class for command line interface.

use App::Sandy::Base 'class';
use Path::Class 'file';

# VERSION

has 'argv' => (
	is      => 'ro',
	isa     => 'ArrayRef',
	default => sub { \@ARGV }
);

has 'progname' => (
	is      => 'ro',
	isa     => 'Str',
	default => file($0)->basename
);

sub opt_spec {
	'help|h',
	'man|u'
}

__END__

=head1 SYNOPSIS

 extends 'App::Sandy::CLI';

=method argv

This mthod returns the \@ARGV

=method progname

This method returns the program name

=method opt_spec

This is the global options method. Child classes may
override it and provides more options by $self->super

=head1 DESCRIPTION

This is the base class for CLI interface 

=head1 SEE ALSO

=for :list
* L<App::Sandy::CLI::App>
* L<App::Sandy::CLI::Command>

=cut
