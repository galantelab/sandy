package App::SimulateReads::Command::Simulate;
# ABSTRACT: simulate command class. Manage genome, transcriptome simulation

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::Command';

our $VERSION = '0.13'; # VERSION

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

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Command::Simulate - simulate command class. Manage genome, transcriptome simulation

=head1 VERSION

version 0.13

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

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
