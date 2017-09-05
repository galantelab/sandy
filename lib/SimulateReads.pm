#
#===============================================================================
#
#         FILE: SimulateReads.pm
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

package SimulateReads;

use My::Base 'class';
use Path::Class 'file';
use Pod::Usage;
use Try::Tiny;

with 'My::Role::ParseArgv';

has 'argv' => (
	is      => 'ro',
	isa     => 'ArrayRef',
	default => sub { \@ARGV }
);

has 'progname' => (
	is      => 'rw',
	isa     => 'Str',
	default => file($0)->basename
);

sub error {
	my ($self, $error_msg) = @_;
	my $progname = $self->progname;
	chomp $error_msg;
	die "$progname: $error_msg\n";
}

sub _try_msg {
	my $self = shift;
	return sprintf "Try '%s --help' for more information" => $self->progname;
}

sub command_loading {
	my ($self, $command_class) = @_;
	eval "require $command_class";
	die $@ if $@;

	my $command_class_path = $INC{ file(split /::/ => "$command_class.pm") }
		or die "$command_class not found in \%INC";

	return $command_class_path;
}

sub opt_spec {
	'help|h',
	'man|M'
}

sub command_map {
	digest    => 'SimulateReads::Command::Digest',
	qualitydb => 'SimulateReads::Command::QualityDB'
}

sub command_map_bultin {
	help      => \&help_command,
	man       => \&man_command
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
	my ($self, $command_path, $argv) = @_;
	$self->error("Too many arguments: '@$argv'") if @$argv;
	my $path = $self->command_loading($command_path) if defined $command_path;
	return $self->help_text($path);
}

sub man_command {
	my ($self, $command_path, $argv) = @_;
	$self->error("Too many arguments: '@$argv'") if @$argv;
	my $path = $self->command_loading($command_path) if defined $command_path;
	return $self->man_text($path);
}

sub run_command_builtin {
	my ($self, $command_name, $command_method, $argv) = @_;
	$self->progname($self->progname . " $command_name");

	my %command_map = $self->command_map;
	my %command_map_bultin = $self->command_map_bultin;
	my $arg_path;

	if (@$argv) {
		my $arg = shift @$argv;
		given ($arg) {
			when (%command_map_bultin) {
				# Do nothing. It prints tha app help/man
			}
			when (%command_map) {
				$arg_path = $command_map{$arg};
			}
			default {
				$self->error("Unknown argument: '$arg'");
			}
		}
	}

	$self->$command_method($arg_path, $argv);
}

sub run_command {
	my ($self, $command_name, $command_class, $argv) = @_;
	$self->progname($self->progname . " $command_name");	

	my $command_class_path = $self->command_loading($command_class);
	my $o = $command_class->new;
	die "Not defined method 'execute' to $command_class" unless $o->can('execute');

	# $args has at least $argv if no opt has been passed
	my ($opts, $args) = (undef, $argv);

	if ($o->can('opt_spec')) {
		try	{
			($opts, $args) = $self->parser($argv, $o->opt_spec);	
		} catch  {
			$self->error("$_" . $self->_try_msg);	
		};
	}

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

	$self->help_text($command_class_path) if $opts->{help};
	$self->man_text($command_class_path) if $opts->{man};

	try {
		$o->execute($opts, $args);
	} catch {
		$self->error($_);
	};
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
			$self->run_command_builtin($command_name, $command_method, \@argv);
		}
		when (%command_map) {
			my $command_name = shift @argv;	
			my $command_class = $command_map{$command_name};
			$self->run_command($command_name, $command_class, \@argv);
		}
		when (/^-/) {
			my ($opts, $args);
			try {
				($opts, $args) = $self->parser(\@argv, $self->opt_spec);
			} catch {
				$self->error("$_" . $self->_try_msg);
			};
			$self->error("Too many arguments: '@$args'") if @$args;
			$self->help_text if $opts->{help};
			$self->man_text if $opts->{man};
		}
		default {
			$self->error("Unknown argument '$argv[0]'\n" . $self->_try_msg);
		}
	}
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

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

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
