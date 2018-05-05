package App::SimulateReads::Command::Quality::Remove;
# ABSTRACT: quality subcommand class. Remove a quality profile from database.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::Quality';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	my $quality_profile = shift @$args;

	if (not defined $quality_profile) {
		die "Missing quality-profile\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $quality_profile = shift @$args;

	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;

	log_msg ":: Attempting to remove '$quality_profile' ...";
	$self->deletedb($quality_profile);
	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 simulate_reads quality remove <quality-profile>

 Arguments:
  a quality-profile entry

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Remove a quality profile from database.

=cut
