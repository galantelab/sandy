package App::Sandy::Command::Quality::Add;
# ABSTRACT: quality subcommand class. Add a quality profile to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Quality';

# VERSION

use constant {
	TYPE_OPT => ['raw', 'fastq']
};

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'quality-profile|q=s',
	'source|s=s',
	'sequencing-error|e=f',
	'single-molecule|1'
};

sub _default_opt {
	'verbose'          => 0,
	'type'             => 'fastq',
	'source'           => 'not defined',
	'sequencing-error' => 0.001,
	'single-molecule'  => 0
}

sub validate_args {
	my ($self, $args) = @_;
	my $file = shift @$args;

	# Mandatory file
	if (not defined $file) {
		die "Missing file (a quality file or fastq file)\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "<$file> is not a file. Please, give me a valid quality or fastq file\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	if (not exists $opts->{'quality-profile'}) {
		die "Option 'quality-profile' not defined\n";
	}

	if (0 > $opts->{'sequencing-error'} || $opts->{'sequencing-error'} > 1)  {
		die "Option 'sequencing-error' requires a value between zero and one, not $opts->{'sequencing-error'}\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $file = shift @$args;

	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Set the type of file
	if ($file !~ /.+\.(fastq)(\.gz)?$/) {
		$opts->{type} = 'raw';
	}

	# Go go go
	log_msg ":: Inserting $opts->{'quality-profile'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'quality-profile'},
		$opts->{'source'},
		1,
		$opts->{'sequencing-error'},
		$opts->{'single-molecule'},
		$opts->{'type'}
	);

	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy quality add -q <entry name> [-s <source>] [-e <error>] [-1] FILE

 Arguments:
  a file (fastq or a file with quality entries only)

 Mandatory options:
  -q, --quality-profile    a quality-profile name

 Options:
  -h, --help               brief help message
  -H, --man                full documentation
  -v, --verbose            print log messages
  -s, --source             quality-profile source detail for database
  -1, --single-molecule    constraint to single-molecule sequencing
                           (as Pacbio and Nanopore)
  -e, --sequencing-error   sequencing error rate
                           [default:"0.001"; Number]

=head1 DESCRIPTION

Add a new quality-profile to the database. The profile will be generated
from the quality strings, which encode the phred-score in ASCII characters
from 0x21 to 0x7e (lowest and highest qualities). So the valid characters
are:

 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~

=head2 INPUT

The user must pass a file in fastq format or a file containing only the
ASCII-encoded phred-scores, as in this example:

 ===> my_qualities.txt
 BECGF@F@DEBIDBE@DCC?HFH?BBB?H@FEEIFDCCECCCIGDIDI?@?CCC?AE?EC?F?@FB;<9<>9:599=>7:57614,30,440&"!***)#
 @DCGIDBDECIHIG@FII?G?GCAD@BFECDCEF?H?GIHE?@GEECBCIHCABAFHDFAHBEBEB:5575678=75>657673-14,.113#"()#&)$
 F?B@@DFAHIDD?EBFADICBFABCBBAHFCGF@@@?DEIAIEAFCEADC?B@IB?BIEABIBG@C<:;96<968:>::;778,+0203-3,#&'$$#&!
 HAAAB@AGAEHC@CHE?EGI?@GFDFFAABDEBHBCDEAA?@IHEBCD@A@HDGFBA?@GHEGIE?5>;>8=75;5<6:<:76,.23-3141#("$"'%"
 CDHC@ADAF?ED?GFFCFBDEE?BDACCEE??DA@?F@ABI@BHGIGFGBBDDBCHHEAIACC@GH<5577:><88;95>9:7///++24.2)"(#%&%$
 ...

=cut
