package App::Sandy::Command::Variation::Restore;
# ABSTRACT: variation subcommand class. Restore database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

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
	log_msg ":: Restoring structural variation database to vendor state ...";
	$self->restoredb;
	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy variation restore

 Options:
  -h, --help               brief help message
  -H, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Restore database.

=cut
