package App::Sandy::Command::Transcriptome;
# ABSTRACT: simulate command class. Simulate transcriptome sequencing

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::Command';

with 'App::Sandy::Role::Digest';

our $VERSION = '0.25'; # VERSION

sub default_opt {
	'paired-end-id'     => '%i.%U:%c %U',
	'single-end-id'     => '%i.%U:%c %U',
	'seed'              => time,
	'verbose'           => 0,
	'prefix'            => 'out',
	'output-dir'        => '.',
	'jobs'              => 1,
	'count-loops-by'    => 'number-of-reads',
	'number-of-reads'   => 1000000,
	'strand-bias'       => 'minus',
	'seqid-weight'      => 'length',
	'sequencing-type'   => 'paired-end',
	'fragment-mean'     => 300,
	'fragment-stdd'     => 50,
	'sequencing-error'  => 0.001,
	'read-mean'         => 100,
	'read-stdd'         => 0,
	'quality-profile'   => 'poisson',
	'join-paired-ends'  => 0,
	'output-format'     => 'fastq.gz',
	'compression-level' => 6
}

sub rm_opt {
	'strand-bias',
	'coverage',
	'seqid-weight',
	'genomic-variation'
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Transcriptome - simulate command class. Simulate transcriptome sequencing

=head1 VERSION

version 0.25

=head1 SYNOPSIS

 sandy transcriptome [options] <fasta-file>

 Arguments:
  a fasta file

 Input/Output options:
  -h, --help                     brief help message
  -H, --man                      full documentation
  -v, --verbose                  print log messages
  -p, --prefix                   prefix output [default:"out"]	
  -o, --output-dir               output directory [default:"."]
  -O, --output-format            bam, sam, fastq.gz, fastq [default:"fastq.gz"]
  -1, --join-paired-ends         merge R1 and R2 outputs in one file
  -x, --compression-level        speed compression: "1" - compress faster,
                                 "9" - compress better [default:"6"; Integer]

 Runtime options:
  -j, --jobs                     number of jobs [default:"1"; Integer]
  -s, --seed                     set the seed of the base generator
                                 [default:"time()"; Integer]

 Sequence identifier options:
  -i, --append-id                append to the defined template id [Format]
  -I, --id                       overlap the default template id [Format]

 Sequencing option:
  -q, --quality-profile          sequencing system profiles from quality
                                 database [default:"poisson"]
  -e, --sequencing-error         sequencing error rate for poisson
                                 [default:"0.001"; Number]
  -m, --read-mean                read mean size for poisson
                                 [default:"100"; Integer]
  -d, --read-stdd                read standard deviation size for poisson
                                 [default:"0"; Integer]
  -t, --sequencing-type          single-end or paired-end reads
                                 [default:"paired-end"]
  -M, --fragment-mean            the fragment mean size for paired-end reads
                                 [default:"300"; Integer]
  -D, --fragment-stdd            the fragment standard deviation size for
                                 paired-end reads [default:"50"; Integer]

 Transcriptome-specific options:
  -n, --number-of-reads          set the number of reads
                                 [default:"1000000", Integer]
  -f, --expression-matrix        an expression-matrix entry from database

=head1 DESCRIPTION

This subcommand simulates transcriptome sequencing reads taking into account
the quality-profile and the expression-matrix weights, along with: raffle
seed; number of reads; fragment mean and standard deviation; single-end
(long and short fragments) and paired-end sequencing type; bam, sam,
fastq.gz and fastq output formats and more.

=head2 INPUT

I<sandy transcriptome> expects as argument a fasta file with transcript sequences.
For example, L<the GENCODE human genome|https://www.gencodegenes.org/human/>
transcript sequences and protein-coding transcript sequences.

=head2 OUTPUT

The output file generated will depend on the I<output-format> (fastq, bam),
on the I<join-paired-ends> option (mate read pairs into a single file) and
on the I<sequencing-type> (single-end, paired-end). One file with the simulated
abundance (${prefix}_abundance_transcripts.tsv) per transcript and one file with
the simulated abundance (${prefix}_abundance_genes.tsv) per gene (if the fasta
file used has the relationship between gene and its transcripts at the header)
will accompany the output file.

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

=item B<--output-format>

Choose the output format. Available options are:
I<bam>, I<sam>, I<fastq.gz>, I<fastq>.
For I<bam> option, B<--append-id> is ignored, considering
that the sequence identifier is splitted by blank character, so
just the first field is included into the query name column
(first column).

=item B<--join-paired-ends>

By default, paired-end reads are put into two different files,
I<prefix_R[12]_001.fastq(\.gz)?>. If the user wants both outputs
together, she can pass this option.
If the B<--id> does not have the escape character %R, it is
automatically included right after the first field (blank separated values)
as in I<id/%R> - which resolves to I<id/1> or I<id/2>.
It is necessary to distinguish which read is R1/R2

=item B<--compression-level>

Regulates the speed of compression using the specified digit (between 1 and 9),
where "1" indicates the fastest compression method (less compression) and "9"
indicates the slowest compression method (best compression). The default
compression level is "6"

=item B<--append-id>

Append string template to the defined template id.
See B<Format>

=item B<--id>

Overlap the default defined template id:
I<single-end> %i.%U %U and I<paired-end> %i.%U %U
e.g. SR123.1 1
See B<Format>

=item B<Format>

A string B<Format> is a combination of literal and escape characters similar to the way I<printf> works.
That way, the user has the freedom to customize the fastq sequence identifier to fit her needs. Valid
escape characteres are:

B<Common escape characters>

	----------------------------------------------------------------------------
	 Escape       Meaning
	----------------------------------------------------------------------------
	 %i   	      instrument id composed by SR + PID
	 %I           job slot number
	 %q           quality profile
	 %e           sequencing error
	 %x           sequencing error position
	 %R           read 1, or 2 if it is the paired-end mate
	 %U           read number
	 %r           read size
	 %m           read mean
	 %d           read standard deviation
	 %c           sequence id as chromossome, gene/transcript id
	 %C           sequence id type (reference or alternate non reference allele) ***
	 %s           read strand
	 %t           read start position
	 %n           read end position
	 %a           read start position regarding reference genome ***
	 %b           read end position regarding reference genome ***
	 %v           genomic variation position ***
	----------------------------------------------------------------------------
	*** specific for genomic variation (genome simulation only)

B<Paired-end specific escape characters>

	----------------------------------------------------------------------------
	 Escape       Meaning
	----------------------------------------------------------------------------
	 %T           mate read start position
	 %N           mate read end position
	 %A           mate read start position regarding reference genome ***
	 %B           mate read end position regarding reference genome ***
	 %D           distance between the paired-reads
	 %M           fragment mean
	 %D           fragment standard deviation
	 %f           fragment size
	 %F           fragment strand
	 %S           fragment start position
	 %E           fragment end position
	 %X           fragment start position regarding reference genome ***
	 %Z           fragment end position regarding reference genome ***
	----------------------------------------------------------------------------
	*** specific for genomic variation (genome simulation only)

=item B<--jobs>

Sets the number of child jobs to be created

=item B<--seed>

Sets the seed of the base generator. The ability to set the seed is
useful for those who want reproducible simulations. Pay attention to
the number of jobs (--jobs) set, because each job receives a different
seed calculated from the I<main seed>. So, for reproducibility, the
same seed set before needs the same number of jobs set before as well.

=item B<--read-mean>

Sets the read mean if quality-profile is equal to 'poisson'. The
quality-profile from database overrides the read-size

=item B<--read-stdd>

Sets the read standard deviation if quality-profile is equal to
'poisson'. The quality-profile from database overrides the read-stdd

=item B<--number-of-reads>

Sets the number of reads desired for each fragment end. That means,
it will be the number of reads for each pair - 1 x N reads for single-end
and 2 x N reads for paired-end. This is the default option for transcriptome
sequencing simulation

=item B<--sequencing-type>

Sets the sequencing type to single-end or paired-end

=item B<--fragment-mean>

If the sequencing-type is set to paired-end, it sets the
fragment mean

=item B<--fragment-stdd>

If the sequencing-type is set to paired-end, it sets the
fragment standard deviation

=item B<--sequencing-error>

Sets the sequencing error rate if quality-profile is equal to 'poisson'.
Valid values are between zero and one

=item B<--quality-profile>

Sets the sequencing system profile for quality. The default value is a poisson
distribution, but the user can choose among several profiles stored into the
database or import his own data.
See B<quality> command for more details

=item B<--expression-matrix>

By default, the gene/transcript is raffled using its length as weight. If
you choose an expression-matrix, then the raffle will be made based on the
gene/transcript expression.
The expression-matrix entries are found into the database.
See B<expression> command for more details

=back

=head1 EXAMPLES

The command:

 $ sandy transcriptome \
 --verbose \
 --jobs=5 \
 --number-of-reads=5000000 \
 --output-dir=my_results/ \
 gencode.v43.transcripts.fa.gz 2> sim.log

or, equivalently:

 $ sandy transcriptome \
 -v -j 5 -n 5000000 -o my_results/ \
 gencode.v43.transcripts.fa.gz 2> sim.log

will both generate two paired-end fastq files (R1 and R2) into my_results/ directory
with 5000000 reads and two abundance files, one per transcripts and the other per genes.

By default the raffled bias is the transcript length, but the user can change this
behavior by choosing an expression-matrix from the database:

 $ sandy transcriptome -f brain_cortex gencode.v43.transcripts.fa.gz

To see the current list of available expression matrices:

 $ sandy expression

And in order to learn how to add your custom expression-matrix, see:

 $ sandy expression add --help

For reproducibility, the user can set the seed option and guarantee the reliability of all
the raffles in a later simulation:

 $ sandy expression --seed=1717 my_transcripts.fa

To simulate reads with a specific quality-profile other than the default
poisson:

 $ sandy expression --quality-profile=hiseq_150 my_transcripts.fa

To see the current list of available quality-profiles:

 $ sandy quality

And in order to learn how to add your custom quality-profile, see:

 $ sandy quality add --help

Sequence identifiers (first lines of fastq entries) may be customized in output using
a format string passed by the user. This format is a combination of literal and escaped
characters, in a similar fashion to that used in C programming language’s printf function.
For example, let’s simulate a paired-end sequencing and add the read length, read position
and mate position into all sequence identifiers:

 $ sandy expression --id="%i.%U read=%c:%t-%n mate=%c:%T-%N length=%r" my_genes.fa.gz

In this case, results would be:

 ==> Into R1
 @SR.1 read=BRAF:979-880 mate=BRAF:736-835 length=100
 ...
 ==> Into R2
 @SR.1 read=BRAF:736-835 mate=BRAF:979-880 length=100
 ...

See B<Format> section for details.

Putting all together:

 $ sandy transcriptome \
 --verbose \
 --jobs=5 \
 --number-of-reads=5000000 \
 --output-dir=my_results/ \
 --expression-matrix=brain_cortex \
 --seed=1717 \
 --quality-profile=hiseq_150 \
 --id="%i.%U read=%c:%t-%n mate=%c:%T-%N length=%r" \
 gencode.v43.transcripts.fa.gz 2> sim.log

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

Rafael Mercuri <rmercuri@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2023 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
