package App::Sandy::Command::Transcriptome;
# ABSTRACT: simulate command class. Simulate transcriptome sequencing

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::Command';

with 'App::Sandy::Role::Digest';

# VERSION

sub default_opt {
	'paired-end-id'    => '%i.%U:%c %U',
	'single-end-id'    => '%i.%U:%c %U',
	'seed'             => time,
	'verbose'          => 0,
	'prefix'           => 'out',
	'output-dir'       => '.',
	'jobs'             => 1,
	'count-loops-by'   => 'number-of-reads',
	'number-of-reads'  => 1000000,
	'strand-bias'      => 'minus',
	'seqid-weight'     => 'length',
	'sequencing-type'  => 'paired-end',
	'fragment-mean'    => 300,
	'fragment-stdd'    => 50,
	'sequencing-error' => 0.001,
	'read-mean'        => 100,
	'read-stdd'        => 0,
	'quality-profile'  => 'poisson',
	'join-paired-ends' => 0,
	'output-format'    => 'fastq.gz'
}

sub rm_opt {
	'strand-bias',
	'coverage',
	'seqid-weight',
	'structural-variation'
}

__END__

=head1 SYNOPSIS

 sandy transcriptome [options] <fasta-file>

 Arguments:
  a fasta-file

 Options:
  -h, --help                     brief help message
  -u, --man                      full documentation
  -v, --verbose                  print log messages
  -p, --prefix                   prefix output [default:"out"]	
  -o, --output-dir               output directory [default:"."]
  -O, --output-format            bam, sam, fastq.gz, fastq [default:"fastq.gz"]
  -1, --join-paired-ends         merge R1 and R2 outputs in one file
  -i, --append-id                append to the defined template id [Format]
  -I, --id                       overlap the default template id [Format]
  -j, --jobs                     number of jobs [default:"1"; Integer]
  -s, --seed                     set the seed of the base generator
                                 [default:"time()"; Integer]
  -n, --number-of-reads          set the number of reads
                                 [default:"1000000", Integer]
  -t, --sequencing-type          single-end or paired-end reads
                                 [default:"paired-end"]
  -q, --quality-profile          sequencing system profiles from quality
                                 database [default:"poisson"]
  -e, --sequencing-error         sequencing error rate for poisson
                                 [default:"0.001"; Number]
  -m, --read-mean                read mean size for poisson
                                 [default:"100"; Integer]
  -d, --read-stdd                read standard deviation size for poisson
                                 [default:"0"; Integer]
  -M, --fragment-mean            the fragment mean size for paired-end reads
                                 [default:"300"; Integer]
  -D, --fragment-stdd            the fragment standard deviation size for
                                 paired-end reads [default:"50"; Integer]
  -f, --expression-matrix        an expression-matrix entry from database


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
	 %v           structural variation position ***
	----------------------------------------------------------------------------
	*** specific for structural variation (genome simulation only)

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
	*** specific for structural variation (genome simulation only)

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

=head1 DESCRIPTION

Simulate transcriptome sequencing.

=cut
