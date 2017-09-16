package App::SimulateReads::Command::QualityDB::Remove;
# ABSTRACT: qualitydb subcommand class. Remove a quality profile from database.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::QualityDB';

# VERSION

sub opt_spec {
	'help|h',
	'man|M',
	'verbose|v',
	'quality-profile|q=s',
	'read-size|r=i'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	
	if (not exists $opts->{'quality-profile'}) {
		die "Option 'quality-profile' not defined\n";
	}

	if (not exists $opts->{'read-size'}) {
		die "Option 'read-size' not defined\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;
	log_msg "Attempting to remove $opts->{'quality-profile'}:$opts->{'read-size'}";
	$self->deletedb($opts->{'quality-profile'}, $opts->{'read-size'});
	log_msg "Done!";
}

__END__

=head1 SYNOPSIS

 simulate_reads qualitydb remove -q <entry name> -r <size>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages
  -q, --quality-profile    quality-profile name for the database [required]
  -r, --read-size          the read-size of the quality-profile [required, Integer]

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=cut
