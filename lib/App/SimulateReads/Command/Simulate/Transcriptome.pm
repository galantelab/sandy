package App::SimulateReads::Command::Simulate::Transcriptome;
# ABSTRACT: simulate subcommand class. Simulate transcriptome sequencing

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::Simulate';

with 'App::SimulateReads::Role::Digest';

our $VERSION = '0.11'; # VERSION

sub default_opt {
	'verbose'          => 0,
	'prefix'           => 'out',
	'output-dir'       => '.',
	'jobs'             => 1,
	'gzip'             => 1,
	'count-loops-by'   => 'number-of-reads',
	'number-of-reads'  => 1000000,
	'strand-bias'      => 'minus',
	'seqid-weight'     => 'file',
	'sequencing-type'  => 'paired-end',
	'fragment-mean'    => 300,
	'fragment-stdd'    => 50,
	'sequencing-error' => 0.005,
	'read-size'        => 101,
	'quality-profile'  => 'hiseq'
}

sub rm_opt {
	'strand-bias',
	'coverage',
	'seqid-weight'
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Command::Simulate::Transcriptome - simulate subcommand class. Simulate transcriptome sequencing

=head1 VERSION

version 0.11

=head1 SYNOPSIS

 simulate_reads simulate transcriptome [options] -f <expression-matrix> <fasta-file>

 Arguments:
  a fasta-file 

 Mandatory options:
  -f, --weight-file        an expression-matrix file

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages
  -p, --prefix             prefix output [default:"out"]	
  -o, --output-dir         output directory [default:"."]
  -j, --jobs               number of jobs [default:"1"; Integer]
  -z, --gzip               compress output file
  -n, --number-of-reads    set the number of reads
                           [default:"1000000", Integer]
  -t, --sequencing-type    single-end or paired-end reads
                           [default:"paired-end"]
  -q, --quality-profile    illumina sequencing system profiles
                           [default:"hiseq"]
  -e, --sequencing-error   sequencing error rate
                           [default:"0.005"; Number]
  -r, --read-size          the read size [default:"101"; Integer]
  -m, --fragment-mean      the fragment mean size for paired-end reads
                           [default:"300"; Integer]
  -d, --fragment-stdd      the fragment standard deviation size for
                           paired-end reads [default:"50"; Integer]

=head1 DESCRIPTION

Simulate transcriptome sequencing.

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--verbose>

Prints log information to standard error

=item B<--prefix>

Concatenates the prefix to the output-file name.

=item B<--output-dir>

Creates output-file inside output-dir. If output-dir
does not exist, it is created recursively

=item B<--jobs>

Sets the number of child jobs to be created

=item B<--gzip>

Compress the output-file with gzip algorithm. It is
possible to pass --no-gzip if one wants
uncompressed output-file

=item B<--read-size>

Sets the read size. For now the unique valid value is 101

=item B<--number-of-reads>

Sets the number of reads desired. This is the default option
for transcriptome sequencing simulation

=item B<--sequencing-type>

Sets the sequencing type to single-end or paired-end

=item B<--fragment-mean>

If the sequencing-type is set to paired-end, it sets the
fragment mean

=item B<--fragment-stdd>

If the sequencing-type is set to paired-end, it sets the
fragment standard deviation

=item B<--sequencing-error>

Sets the sequencing error rate. Valid values are between zero and one

=item B<--quality-profile>

Sets the illumina sequencing system profile for quality. For now, the unique
valid values are hiseq and poisson

=item B<--weight-file>

A valid weight file is an expression-matrix file with 2 columns. The first column is
for the seqid and the second column is for the count. The counts will be treated as weights

=back

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
