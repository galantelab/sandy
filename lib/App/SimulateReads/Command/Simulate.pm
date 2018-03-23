package App::SimulateReads::Command::Simulate;
# ABSTRACT: simulate command class. Manage genome, transcriptome simulation

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::Command';

# VERSION

override 'opt_spec' => sub {
	super,
	'help|h'
};

sub subcommand_map {
	custom        => 'App::SimulateReads::Command::Simulate::Custom',
	genome        => 'App::SimulateReads::Command::Simulate::Genome',
	transcriptome => 'App::SimulateReads::Command::Simulate::Transcriptome',
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	print <<"HELP";
simulate_reads simulate <command>

Commands:
 genome                   simulate genome sequencing
 transcriptome            simulate transcriptome sequencing
 custom                   simulate a custom sequencing
HELP
}

__END__

=head1 SYNOPSIS

 simulate_reads simulate
 simulate_reads simulate [options]
 simulate_reads simulate <command>

 Manage simulation

 Options:
  -h, --help               brief help message
  -M, --man                full documentation

 Commands:
  genome                   simulate genome sequencing
  transcriptome            simulate transcriptome sequencing
  custom                   simulate a custom sequencing

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=cut
