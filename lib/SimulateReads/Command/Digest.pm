#
#===============================================================================
#
#         FILE: Digest.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02-09-2017 21:00:07
#     REVISION: ---
#===============================================================================

package SimulateReads::Command::Digest;

use My::Base 'class';
use Pod::Usage;

sub opt_spec {
	'help|h',
	'man|M',
	'prefix|p=s',
	'jobs|j=i'
}

sub validate {
	my ($self, $opts, $argv) = @_;
	die "Option 'jobs' needs to be a positive integer, not '$opts->{jobs}'\n"
		if exists $opts->{jobs} and $opts->{jobs} < 0;
}

sub execute {
	my ($self, $opts, $argv) = @_;
	say "Digest";
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

=head1 SYNOPSIS

 simulate_reads digest [options] <fasta-file>

 Arguments:
  a fasta-file 

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages
  -p, --prefix             prefix output [default:"out"]	
  -o, --output-dir         output directory [default:"."]
  -j, --jobs               number of jobs [default:"1"; Integer]
  -z, --output-gzip        compress output file
  -c, --coverage           fastq-file coverage [default:"1", Number]
  -n, --number-of-reads    directly set the number of reads
                           [default:"1", Integer]
  -t, --sequencing-type    single-end or paired-end reads
                           [default:"paired-end"]
  -q, --quality-profile    illumina sequencing system profiles
                           [default:"hiseq"]
  -e, --sequencing-error   sequencing error rate
                           [default:"0.005"; Number]
  -r, --read-size          the read size [default:"101"; Integer]
  -m, --fragment-mean      the mean size fragments for paired-end reads
                           [default:"300"; Integer]
  -d, --fragment-stdd      the standard deviation for fragment sizes
                           [default:"50"; Integer]
  -b, --strand-bias        which strand to be used: plus, minus and random
                           [default:"random"]
  -w, --seqid-weight       seqid raffle type: length, same, file
                           [default: "length"]
  -f, --weight-file        weight file when seqid-weight=file

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

=item B<--output-gzip>

Compress the output-file with gzip algorithm. It is
possible to pass --no-output-gzip if one wants
uncompressed output-file

=item B<--read-size>

Sets the read size. For now the unique valid value is 101

=item B<--coverage>

Calculates the number of reads based on the sequence
coverage: number_of_reads = (sequence_size * coverage) / read_size

=item B<--number-of-reads>

Sets directly the number of reads desired. It overrides coverage,
in case the two options are given

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

=item B<--strand-bias>

Sets which strand to use to make a read. Valid options are plus, minus and
random - if you want to randomly calculte the strand for each read

=item B<--seqid-weight>

Sets the seqid (e.g. chromossome, ensembl id) raffle behavior. Valid options are
length, same and file. If it is set to 'same', all seqid receives the same weight
when raffling. If it is set to 'length', the seqid weight is calculated based on
the seqid sequence length. And finally, if it is set to 'file', the user must set
the option --weight-file. For details, see B<--weight-file>

=item B<--weight-file>

If --seqid-weight is set to file, then this option becomes mandatory. A valid
weight file is a tab-separated values file with 2 columns. The first column is
for the seqid and the second column for the desired weight. Valid weights are integers

=back

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
