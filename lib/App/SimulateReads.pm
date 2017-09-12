package App::SimulateReads;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::SimulateReads::Base 'class';
use Path::Class 'file';
use Pod::Usage;
use Try::Tiny;

with 'App::SimulateReads::Role::ParseArgv';

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

sub opt_spec {
	'help|h',
	'man|M'
}

sub command_map {
	digest    => 'App::SimulateReads::Command::Digest',
	qualitydb => 'App::SimulateReads::Command::QualityDB'
}

sub command_map_bultin {
	help      => \&help_command,
	man       => \&man_command
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

sub help_text {
	my ($self, $path) = @_;
	$path ||= __FILE__;
	pod2usage(-input => $path, -verbose => 99, -sections => ['SYNOPSIS'], -exitval => 0);
}

sub man_text {
	my ($self, $path) = @_;
	$path ||= __FILE__;
	pod2usage(-input => $path, -verbose => 2, -exitval => 0);
}

sub help_command {
	my ($self, $argv) = @_;
	my %command_map = $self->command_map;
	$self->_dispatcher(\%command_map, $argv);
	$self->error("Too many arguments: '@$argv'") if @$argv;
	my $path;
	$path = $self->get_command(-1)->{path} unless $self->has_no_command;
	return $self->help_text($path);
}

sub man_command {
	my ($self, $argv) = @_;
	my %command_map = $self->command_map;
	$self->_dispatcher(\%command_map, $argv);
	$self->error("Too many arguments: '@$argv'") if @$argv;
	my $path;
	$path = $self->get_command(-1)->{path} unless $self->has_no_command;
	return $self->man_text($path);
}

sub run_no_command {
	my ($self, $argv) = @_;
	my ($opts, $args);

	try {
		($opts, $args) = $self->parser($argv, $self->opt_spec);
	} catch {
		$self->error("$_" . $self->_try_msg);
	};

	$self->help_text if $opts->{help};
	$self->man_text if $opts->{man};
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
			($opts, $args) = $self->parser($argv, $o->opt_spec);	
		} catch  {
			$self->error("$_" . $self->_try_msg);	
		};
	}

	$self->help_text($command->{path}) if $opts->{help};
	$self->man_text($command->{path}) if $opts->{man};

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

	$self->help_text unless scalar @argv;

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

 simulate_reads [options]
 simulate_reads help <command>
 simulate_reads <command> ...

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Help commands
  help                     show application or command-specific help
  man                      show application or command-specific documentation

 Main commands:
  digest                   digest a fasta file into single|paired-end reads 
  qualitydb                manage quality profile database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=cut
