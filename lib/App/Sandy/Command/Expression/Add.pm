package App::Sandy::Command::Expression::Add;
# ABSTRACT: expression subcommand class. Add an expression-matrix to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Expression';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'expression-matrix|f=s',
	'source|s=s'
};

sub _default_opt {
	'verbose' => 0,
	'source'  => 'not defined'
}

sub validate_args {
	my ($self, $args) = @_;
	my $file = shift @$args;

	# Mandatory file
	if (not defined $file) {
		die "Missing an expression-matrix file\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "'$file' is not a file. Please, give me a valid expression-matrix file\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	if (not exists $opts->{'expression-matrix'}) {
		die "Mandatory option 'expression-matrix' not defined\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $file = shift @$args;

	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Go go go
	log_msg ":: Inserting $opts->{'expression-matrix'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'expression-matrix'},
		$opts->{'source'},
		1
	);

	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy expression add -f <entry name> [-s <source>] FILE

 Arguments:
  an expression-matrix file

 Mandatory options:
  -f, --expression-matrix    an expression-matrix name

 Options:
  -h, --help                 brief help message
  -u, --man                  full documentation
  -v, --verbose              print log messages
  -s, --source               expression-matrix source detail for database

=head1 DESCRIPTION

Add an expression-matrix to the database. A valid expression-matrix is a
file with two columns. The first column is for the seqid and the second
column is for the raw count. The counts will be treated as weights.

=head2 INPUT

A two-columns whitespace separated file, where the first column is the
transcript id, or the gene id, and the second column is the raw counts.

 ===> my_custom_expression_matrix.txt
 #feature	count
 ENST00000000233.9	2463
 ENST00000000412.7	2494
 ENST00000000442.10	275
 ENST00000001008.5	5112
 ENST00000001146.6	637
 ENST00000002125.8	660
 ENST00000002165.10	478
 ENST00000002501.10	57
 ENST00000002596.5	183
 ...

=cut
