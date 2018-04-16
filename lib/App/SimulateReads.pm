package App::SimulateReads;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::App';

# VERSION

sub command_map {
	custom        => 'App::SimulateReads::Command::Custom',
	genome        => 'App::SimulateReads::Command::Genome',
	transcriptome => 'App::SimulateReads::Command::Transcriptome',
	quality       => 'App::SimulateReads::Command::Quality',
	expression    => 'App::SimulateReads::Command::Expression'
}

__END__

=head1 SYNOPSIS

 simulate_reads [options]
 simulate_reads help <command>
 simulate_reads <command> ...

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Help commands:
  help                     show application or command-specific help
  man                      show application or command-specific documentation

 Main commands:
  genome                   simulate genome sequencing
  transcriptome            simulate transcriptome sequencing
  custom                   simulate custom sequencing
  quality                  manage quality profile database
  expression               manage expression-matrix database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=cut
