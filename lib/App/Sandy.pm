package App::Sandy;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::App';

our $VERSION = '0.23'; # VERSION

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

version 0.23

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

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

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
