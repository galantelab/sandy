package App::Sandy::CLI::App;
# ABSTRACT: App::Sandy::CLI subclass for command line application interface.

use App::Sandy::Base 'class';
use Path::Class 'file';
use Pod::Usage;
use Try::Tiny;

extends 'App::Sandy::CLI';

with 'App::Sandy::Role::ParseArgv';

# VERSION

has 'command_stack' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	default => sub { [] },
	handles => {
		add_command    => 'push',
		get_command    => 'get',
		map_command    => 'map',
		has_no_command => 'is_empty'
	}
);

has 'app_path' => (
	is      => 'ro',
	isa     => 'Str',
	builder => '_build_app_path'
);

sub _build_app_path {
	# Determine dynamic the app path that inherit from this class
	# If no one is inheriting, return this class path
	my $class = (caller(1))[3];
	$class =~ s/::new//;
	my $command_pm = file(split /::/ => "$class.pm");
	return $INC{$command_pm};
}

override 'opt_spec' => sub {
	super
};

sub command_map_bultin {
	help => \&help_command,
	man  => \&man_command
}

sub command_map {
	# It needs to be override
}

sub error {
	my ($self, $error_msg) = @_;
	my $sender = $self->_whois;
	chomp $error_msg;
	die "$sender: $error_msg\n";
}

sub _whois {
	my $self = shift;
	my $sender = $self->progname;
	my @commands = $self->map_command(sub { $_->{name} });
	$sender .= " @commands" unless $self->has_no_command;
	return $sender;
}

sub _try_msg {
	my $self = shift;
	return sprintf "Try '%s --help' for more information" => $self->_whois;
}

sub _help_text {
	my ($self, $path) = @_;
	$path ||= $self->app_path;
	pod2usage(-input => $path, -verbose => 99, -sections => ['SYNOPSIS'], -exitval => 0);
}

sub _man_text {
	my ($self, $path) = @_;
	$path ||= $self->app_path;
	pod2usage(-input => $path, -verbose => 2, -exitval => 0);
}

sub help_command {
	my ($self, $argv) = @_;
	my %command_map = $self->command_map;
	$self->_dispatcher(\%command_map, $argv);
	$self->error("Too many arguments: '@$argv'\n" . $self->_try_msg) if @$argv;
	my $path;
	$path = $self->get_command(-1)->{path} unless $self->has_no_command;
	return $self->_help_text($path);
}

sub man_command {
	my ($self, $argv) = @_;
	my %command_map = $self->command_map;
	$self->_dispatcher(\%command_map, $argv);
	$self->error("Too many arguments: '@$argv'\n" . $self->_try_msg) if @$argv;
	my $path;
	$path = $self->get_command(-1)->{path} unless $self->has_no_command;
	return $self->_man_text($path);
}

sub run_no_command {
	my ($self, $argv) = @_;
	my ($opts, $args);

	try {
		($opts, $args) = $self->with_parser($argv, $self->opt_spec);
	} catch {
		$self->error("$_" . $self->_try_msg);
	};

	$self->_help_text if $opts->{help};
	$self->_man_text if $opts->{man};
}

sub run_command {
	my ($self, $argv) = @_;
	my %command_map = $self->command_map;
	$self->_dispatcher(\%command_map, $argv);

	my $command = $self->get_command(-1);
	my $o = $command->{class}->new;

	# $args has at least $argv if no opt has been passed
	my ($opts, $args) = (undef, $argv);

	if ($o->can('opt_spec')) {
		try	{
			($opts, $args) = $self->with_parser($argv, $o->opt_spec);
		} catch  {
			$self->error("$_" . $self->_try_msg);
		};
	}

	$self->_help_text($command->{path}) if $opts->{help};
	$self->_man_text($command->{path}) if $opts->{man};

	# Deep copy the arguments, just in case the user
	# manages to mess with
	my %opts_copy = %$opts;
	my @args_copy = @$args;

	if ($o->can('validate_args')) {
		try {
			$o->validate_args(\@args_copy);
		} catch {
			$self->error("$_" . $self->_try_msg);
		};
	}

	if ($o->can('validate_opts')) {
		try {
			$o->validate_opts(\%opts_copy);
		} catch {
			$self->error("$_" . $self->_try_msg);
		};
	}

	try {
		$o->execute($opts, $args);
	} catch {
		$self->error($_);
	};
}

sub _command_loading {
	my ($self, $command_class) = @_;
	my $command_pm = file(split /::/ => "$command_class.pm");

	eval { require $command_pm };
	die $@ if $@;

	my $command_class_path = $INC{ $command_pm }
		or die "$command_class not found in \%INC";

	return $command_class_path;
}

sub _dispatcher {
	my ($self, $command_map, $argv) = @_;

	if (@$argv && exists $command_map->{$argv->[0]}) {
		my $command_name = shift @$argv;
		my $command_class = $command_map->{$command_name};
		my $command_class_path = $self->_command_loading($command_class);

		$self->add_command({
			'name'  => $command_name,
			'class' => $command_class,
			'path'  => $command_class_path
		});

		unless ($command_class->can('execute')) {
			die "Not defined method 'execute' for $command_class";
		}

		if ($command_class->can('subcommand_map')) {
			my %command_map = $command_class->subcommand_map;
			return $self->_dispatcher(\%command_map, $argv);
		}
	}
}

sub run {
	my $self = shift;
	my @argv = @{ $self->argv };
	my %command_map = $self->command_map;
	my %command_map_bultin = $self->command_map_bultin;

	$self->_help_text unless scalar @argv;

	given ($argv[0]) {
		when (%command_map_bultin) {
			my $command_name = shift @argv;
			my $command_method = $command_map_bultin{$command_name};
			$self->$command_method(\@argv);
		}
		when (%command_map) {
			$self->run_command(\@argv);
		}
		when (/^-/) {
			$self->run_no_command(\@argv);
		}
		default {
			$self->error("Unknown command '$argv[0]'\n" . $self->_try_msg);
		}
	}
}

__END__

=head1 SYNOPSIS

 extends 'App::Sandy::CLI::App';

=method command_stack

This method returns a stach with commands and subcommands

=method app_path

This method returns the application class path

=method command_map_bultin

This method retuns a hash with bultin command

=method command_map

This method needs to be override by child to provide
command arguments. It is expected to return a hash

=method error

This method prints a formatted error message

=method help_command

This method calls help message to the command up
in the C<command_stack>. If no command was passed,
it calls help message to the app itself. Help messages
are in pod format inside the app, command classes

=method man_command

This method calls man message to the command up
in the C<command_stack>. If no command was passed,
it calls man message to the app itself. Man messages
are in pod format inside the app, command classes

=method run_no_command

This method runs app options, those defined in
C<opt_spec> method

=method run_command

This method checkes C<command_stack> and executes the
command up mathods C<validate_args>, C<validate_opts>
and C<execute>

=method run

This method checks the arguments passed to the
application and call the appropriate methods
C<run_no_command>, C<run_command> or
C<help_command>/C<man_command>

=head1 DESCRIPTION

This is the base interface to application class.
Classes need to override command_map method to
provide command arguments

=head1 SEE ALSO

=for :list
* L<App::Sandy::CLI::Command>

=cut
