package App::SimulateReads;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::App';

# VERSION

sub command_map {
	digest    => 'App::SimulateReads::Command::Digest',
	qualitydb =>  'App::SimulateReads::Command::QualityDB'
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
