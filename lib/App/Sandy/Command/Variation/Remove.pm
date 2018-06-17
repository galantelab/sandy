package App::Sandy::Command::Variation::Remove;
# ABSTRACT: variation subcommand class. Remove structural variation from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	my $structural_variation = shift @$args;

	# Mandatory file
	if (not defined $structural_variation) {
		die "Missing structural variation\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $structural_variation = shift @$args;

	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;

	log_msg ":: Attempting to remove $structural_variation ...";
	$self->deletedb($structural_variation);
	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy variation remove <structural variation>

 Arguments:
  a structural variation entry

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Remove structural variation from database.

=cut
