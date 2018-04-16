package App::SimulateReads;
# ABSTRACT: App builder that simulates single-end and paired-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::App';

our $VERSION = '0.16'; # VERSION

sub command_map {
	custom        => 'App::SimulateReads::Command::Custom',
	genome        => 'App::SimulateReads::Command::Genome',
	transcriptome => 'App::SimulateReads::Command::Transcriptome',
	quality       => 'App::SimulateReads::Command::Quality',
	expression    => 'App::SimulateReads::Command::Expression'
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads - App builder that simulates single-end and paired-end reads.

=head1 VERSION

version 0.16

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
  genome                   simulate genome sequencing
  transcriptome            simulate transcriptome sequencing
  custom                   simulate custom sequencing
  quality                  manage quality profile database
  expression               manage expression-matrix database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
