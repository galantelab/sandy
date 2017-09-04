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

sub command_map {
	digest    => 'SimulateReads::Command::Digest',
	qualitydb => 'SimulateReads::Command::QualityDB'
}

sub run_command {
	my ($self, $command_name, $command_class, $argv) = @_;
	$self->progname($self->progname . " $command_name");	

	eval "require $command_class";
	die $@ if $@;

	my $command_class_path = $INC{ file(split /::/ => "$command_class.pm") }
		or die "$command_class not found in \%INC";

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

	$self->help_text unless scalar @argv;

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
			$self->error("Too many arguments: '@$args'") if @$args;
			$self->help_text if $opts->{help};
			$self->man_text if $opts->{man};
		}
		default {
			$self->error("Unknown argument '$argv[0]'");
		}
	}
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

=head1 SYNOPSIS

 simulate_reads [options]
 simulate_reads <command> --help

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  help                     show application or command-specific help
  digest                   digest a fasta file into single|paired-end reads 
  qualitydb                manage quality profile database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
