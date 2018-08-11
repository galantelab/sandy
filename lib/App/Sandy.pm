package App::Sandy;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::App';

our $VERSION = '0.19'; # VERSION

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

version 0.19

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

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

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
