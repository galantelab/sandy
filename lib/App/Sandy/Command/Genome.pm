package App::Sandy::Command::Genome;
# ABSTRACT: simulate command class. Simulate genome sequencing

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::Command';

with 'App::Sandy::Role::Digest';

# VERSION

sub default_opt {
	'paired-end-id'    => '%i.%U:%c:%F:%X-%Z',
	'single-end-id'    => '%i.%U:%c:%s:%t-%n',
	'seed'             => time,
	'verbose'          => 0,
	'prefix'           => 'out',
	'output-dir'       => '.',
	'jobs'             => 1,
	'count-loops-by'   => 'coverage',
	'coverage'         => 8,
	'strand-bias'      => 'random',
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
	'number-of-reads',
	'seqid-weight',
	'expression-matrix'
}

__END__

=head1 SYNOPSIS

 sandy genome [options] <fasta-file>

 Arguments:
  a fasta-file

 Options:
  -h, --help                         brief help message
  -u, --man                          full documentation
  -v, --verbose                      print log messages
  -p, --prefix                       prefix output [default:"out"]
  -o, --output-dir                   output directory [default:"."]
  -O, --output-format                bam, sam, fastq.gz, fastq [default:"fastq.gz"]
  -1, --join-paired-ends             merge R1 and R2 outputs in one file
  -i, --append-id                    append to the defined template id [Format]
  -I, --id                           overlap the default template id [Format]
  -j, --jobs                         number of jobs [default:"1"; Integer]
  -s, --seed                         set the seed of the base generator
                                     [default:"time()"; Integer]
  -c, --coverage                     fastq-file coverage [default:"8", Number]
  -t, --sequencing-type              single-end or paired-end reads
                                     [default:"paired-end"]
  -q, --quality-profile              sequencing system profiles from quality
                                     database [default:"poisson"]
  -e, --sequencing-error             sequencing error rate for poisson
                                     [default:"0.001"; Number]
  -m, --read-mean                    read mean size for poisson
                                     [default:"100"; Integer]
  -d, --read-stdd                    read standard deviation size for poisson
                                     [default:"0"; Integer]
  -M, --fragment-mean                the fragment mean size for paired-end reads
                                     [default:"300"; Integer]
  -D, --fragment-stdd                the fragment standard deviation size for
                                     paired-end reads [default:"50"; Integer]
  -a, --structural-variation         a list of structural variation entries from
                                     variation database. This option may be passed
                                     multiple times [default:"none"]
  -A, --structural-variation-regex   a list of perl-like regex to match structural
                                     variation entries in variation database.
                                     This option may be passed multiple times
                                     [default:"none"]

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
I<single-end> %i.%U_%c_%s_%t_%n and I<paired-end> %i.%U_%c_%s_%S_%E
e.g. SR123.1_chr1_P_1001_1101
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

=item B<--coverage>

Calculates the number of reads based on the sequence
coverage: number_of_reads = (sequence_size * coverage) / read_size.
This is the default option for genome sequencing simulation

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

=item B<--structural-variation>

Sets the structural variation to be applied on the genome feeded. By
default no variation is included to the simulation, but the user has
the power to point some entries from B<variation> database or index his
own data. This option accepts a list with comma separated values
and can be passed multiple times, which is useful in order to join
various types of structural variation into the same simulation. It is
possible to combine this option with B<--structural-variation-regex>
See B<variation> command for the available list of structural variation
entries

=item B<--structural-variation-regex>

Applies perl-regex in the variation database and selects all entryes
that match the pattern. This option accepts a list with comma separated
values and can be passed multiple times. It is possible to combine this
option with B<--structural-variation>
See B<variation> command for the available list of structural variation
entries

=back

=head1 DESCRIPTION

Simulate genome sequencing.

=cut
