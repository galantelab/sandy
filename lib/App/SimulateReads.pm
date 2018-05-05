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
	expression    => 'App::SimulateReads::Command::Expression',
	version       => 'App::SimulateReads::Command::Version'
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

 Misc commands:
  version                  print the current version

 Main commands:
  genome                   simulate genome sequencing
  transcriptome            simulate transcriptome sequencing
  custom                   simulate custom sequencing
  quality                  manage quality profile database
  expression               manage expression-matrix database

=head1 DESCRIPTION

B<SANDY> is a bioinformatic tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file. Many next-generation sequencing
(NGS) analyses rely on hypothetical models and principles that are not precisely
satisfied in practice. Simulated data, which provides positive controls would be a
perfect way to overcome these difficulties. Nevertheless, most of NGS simulators are
extremely complex to use, they do not cover all kinds of the desired features needed
by the users, and (some) are very slow to run in a standard computer. Here, we present
SANDY, a straightforward, easy to use, fast, complete set of tools to generate synthetic
next-generation sequencing reads. SANDY simulates whole genome sequencing, whole exome
sequencing, RNAseq reads and it presents several features to the users manipulate the data.
SANDY can be used therefore for benchmarking results of a variety of pipelines in the
genomics or trancriptomics.

=cut
