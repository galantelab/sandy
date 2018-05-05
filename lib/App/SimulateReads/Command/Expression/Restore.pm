package App::SimulateReads::Command::Expression::Restore;
# ABSTRACT: expression subcommand class. Restore database.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::Expression';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;
	log_msg ":: Restoring expression-matrix database to vendor state ...";
	$self->restoredb;
	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 simulate_reads expression restore

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Restore database.

=cut
