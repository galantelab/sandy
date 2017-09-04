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
	die "$progname: $error_msg\nTry '$progname --help' for more information\n";
}

sub opt_spec {
	'help|h',
	'man|M'
}

sub command_map {
	digest    => 'SimulateReads::Command::Digest',
	qualitydb => 'SimulateReads::Command::QualityDB'
}

sub run_command {
	my ($self, $command_name, $command_class, $argv) = @_;
	$self->progname($self->progname . " $command_name");	

	eval "require $command_class";
	die $@ if $@;

	my $o = $command_class->new;
	die "Not defined method 'execute' to $command_class" unless $o->can('execute');

	my ($opts, $args) = (undef, $argv);

	if ($o->can('opt_spec')) {
		try	{
			($opts, $args) = $self->parser($argv, $o->opt_spec);	
		} catch  {
			$self->error($_);	
		};
	}

	if ($o->can('validate')) {
		try {
			$o->validate($opts, $args);
		} catch {
			$self->error($_);	
		};
	}

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

	exit unless scalar @argv;

	given ($argv[0]) {
		when ('help') {
			say "help command";
		}
		when ('command') {
			say 'command';
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
				$self->error($_);
			};
			require Data::Dumper;
			print Data::Dumper::Dumper($opts) if defined $opts;
			print Data::Dumper::Dumper($args) if defined $args;
		}
		default {
			$self->error("Unknown argument '$argv[0]'");
		}
	}
}
