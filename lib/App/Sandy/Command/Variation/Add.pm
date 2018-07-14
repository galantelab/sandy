package App::Sandy::Command::Variation::Add;
# ABSTRACT: variation subcommand class. Add structural variation to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'structural-variation|a=s',
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
		die "Missing a structural variation file\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "'$file' is not a file. Please, give me a valid structural variation file\n";
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

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Go go go
	log_msg ":: Inserting $opts->{'structural-variation'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'structural-variation'},
		$opts->{'source'},
		1
	);

	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy variation add -a <entry name> [-s <source>] FILE

 Arguments:
  a structural variation file

 Mandatory options:
  -a, --structural-variation    a structural variation name

 Options:
  -h, --help                    brief help message
  -M, --man                     full documentation
  -v, --verbose                 print log messages
  -s, --source                  structural variation source detail for database

=head1 OPTIONS

=over 8

=item B<--structural-variation>

A valid structural-variation is a file ...

=back

=head1 DESCRIPTION

Add structural-variation to the database.

=cut
