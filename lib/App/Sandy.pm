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

B<SANDY> is a bioinformatics tool that provides a simple engine to simulate next-generation
sequencing for genomic and transcriptomic data. Simulated data works as experimental control
- a key step to optimize NGS analysis - in comparison to hypothetical models. SANDY is a
straightforward, easy-to-use, fast and highly customizable tool that generates reads requiring
only a FASTA file as input. SANDY can simulate single/paired-end reads from both whole exome
sequencing and RNA-seq as if produced from the most used second and third-generation sequencing
platforms. SANDY’s reads can be simulated with genetic variations such as SNVs, indels and gene
fusions. For customization purposes, SANDY have built-in (native) databases that can be easily
extended with varying gene/transcript expression profiles, sequencing errors, sequencing
coverages and genomic variations.

=cut
