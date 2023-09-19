package App::Sandy::Command::Variation::Add;
# ABSTRACT: variation subcommand class. Add structural variation to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

our $VERSION = '0.25'; # VERSION

use constant {
	TYPE_OPT => ['raw', 'vcf']
};

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'structural-variation|a=s',
	'source|s=s',
	'sample-name|n=s'
};

sub _default_opt {
	'verbose' => 0,
	'type'    => 'raw',
	'source'  => 'not defined'
}

sub validate_args {
	my ($self, $args) = @_;
	my $file = shift @$args;

	# Mandatory file
	if (not defined $file) {
		die "Missing file (a variation file or vcf file)\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "'$file' is not a file. Please, give me a valid file\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	if (not exists $opts->{'structural-variation'}) {
		die "Mandatory option 'structural-variation' not defined\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $file = shift @$args;

	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Set the type of file
	if ($file =~ /^.+\.vcf(\.gz)?$/) {
		$opts->{'type'} = 'vcf';
	}

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Go go go
	log_msg ":: Inserting $opts->{'structural-variation'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'structural-variation'},
		$opts->{'source'},
		1,
		$opts->{'type'},
		$opts->{'sample-name'}
	);

	log_msg ":: Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Variation::Add - variation subcommand class. Add structural variation to the database.

=head1 VERSION

version 0.25

=head1 SYNOPSIS

 sandy variation add -a <entry name> [-s <source>] FILE

 Arguments:
  a file (vcf or a genomic-variation file)

 Mandatory options:
  -a, --genomic-variation       genomic-variation entries

 Options:
  -h, --help                    brief help message
  -H, --man                     full documentation
  -v, --verbose                 print log messages
  -s, --source                  genomic-variation source detail for database
  -n, --sample-name             the sample-name present in one of the optional
                                vcf columns SAMPLES from which the genotype
                                will be extracted

=head1 DESCRIPTION

Add genomic-variation to the database. A genomic-variation may be
represented  by a genomic position (seqid, position), a reference
sequence at that postion, an alternate sequence and a genotype
(homozygous or heterozygous).

=head2 INPUT

The input file may be a vcf or a custom genomic-variation file.
For vcf files, the user can point out the sample-name present in
vcf header and then its column will be used to extract the
genotype. if the user does not pass the option I<--sample-name>,
then it will be used the first sample.

 ===> my_variations.vcf
 ##fileformat=VCFv4.3
 ...
 #CHROM POS     ID    REF ALT   QUAL FILTER INFO        FORMAT NA001 NA002
 chr20  14370   rs81  G   A     29   PASS   NS=3;DP=14  GT     0/1   0/0
 chr20  17330   rs82  T   AAA   3    PASS   NS=3;DP=20  GT     1/1   0/0
 chr20  110696  rs83  A   GTCT  10   PASS   NS=2;DP=11  GT     0/1   1/1
 ...

In the I<my_variations.vcf> file, if the user does not point out the
sample I<NA002> by passing the options I<--sample-name=NA002>, the
sample I<NA001> will be used by default.

A genomic-variation file is a representation of a reduced VCF, that
is, without the columns: QUAL, FILTER, INFO and FORMAT. There is only
one SAMPLE column with the genotype for the entry in the format I<HO>
for homozygous and I<HE> for heterozygous. See the example bellow:

 ===> my_variations.txt
 #seqid	position  id	  reference	alternate	genotype
 chr20  14370     rs81  G         A         HE
 chr20  17330     rs82  T         AAA       HO
 chr20  110696    rs83  A         GTCT      HE
 ...

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
