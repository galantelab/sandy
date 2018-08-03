package App::Sandy;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::App';

# VERSION

sub command_map {
	genome        => 'App::Sandy::Command::Genome',
	transcriptome => 'App::Sandy::Command::Transcriptome',
	quality       => 'App::Sandy::Command::Quality',
	expression    => 'App::Sandy::Command::Expression',
	variation     => 'App::Sandy::Command::Variation',
	version       => 'App::Sandy::Command::Version',
	citation      => 'App::Sandy::Command::Citation'
}

__END__

=head1 SYNOPSIS

 sandy [options]
 sandy help <command>
 sandy <command> ...

 Options:
  -h, --help               brief help message
  -u, --man                full documentation
 
 Help commands:
  help                     show application or command-specific help
  man                      show application or command-specific documentation

 Misc commands:
  version                  print the current version
  citation                 export citation in BibTeX format

 Database commands:
  quality                  manage quality profile database
  expression               manage expression-matrix database
  variation                manage structural variation database

 Main commands:
  genome                   simulate genome sequencing
  transcriptome            simulate transcriptome sequencing

=head1 DESCRIPTION

B<Sandy> is a bioinformatic tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file. Many next-generation sequencing
(NGS) analyses rely on hypothetical models and principles that are not precisely
satisfied in practice. Simulated data, which provides positive controls would be a
perfect way to overcome these difficulties. Nevertheless, most of NGS simulators are
extremely complex to use, they do not cover all kinds of the desired features needed
by the users, and (some) are very slow to run in a standard computer. Here, we present
Sandy, a straightforward, easy to use, fast, complete set of tools to generate synthetic
next-generation sequencing reads. Sandy simulates whole genome sequencing, whole exome
sequencing, RNAseq reads and it presents several features to the users manipulate the data.
Sandy can be used therefore for benchmarking results of a variety of pipelines in the
genomics or trancriptomics.

=cut
