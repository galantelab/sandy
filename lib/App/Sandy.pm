package App::Sandy;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::App';

our $VERSION = '0.22'; # VERSION

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

=pod

=encoding UTF-8

=head1 NAME

App::Sandy - App builder that simulates single-end and paired-end reads.

=head1 VERSION

version 0.22

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
single-end/paired-end reads from a given fasta file. Many next-generation
sequencing analyses rely on hypothetical models and principles that are
not precisely satisfied in practice. Simulated data, which provides positive
controls, would be a perfect way to overcome these difficulties. Here, we
present Sandy, a straightforward, easy to use, fast, complete set of tools
to generate synthetic second and third-generation sequencing reads. Sandy
simulates whole genome sequencing, whole exome sequencing, RNAseq reads.
Sandy presents also several features to the users manipulate the data, as
well as well-organized database containing the ‘true’ information (based on
the generated data) of the reads position into the genome, gene and transcript
expression, sequencing errors, and the sequencing coverage. One of the most
impressive features of Sandy is the power to simulate polymorphisms as snvs,
indels and structural variations (e.g. gene duplication, retro-duplication,
gene-fusion) along with the sequencing reads - with no need of further processing
steps. Sandy can be used therefore for benchmarking results of a variety of
pipelines in the genomics or transcriptomics, as well as in generating new
hypotheses and helping in the best designing of sequencing projects, possibly
optimizing time and costs.

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
