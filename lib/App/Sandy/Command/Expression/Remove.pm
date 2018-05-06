package App::Sandy::Command::Expression::Remove;
# ABSTRACT: expression subcommand class. Remove an expression-matrix from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Expression';

# VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

sub validate_args {
	my ($self, $args) = @_;
	my $expression_matrix = shift @$args;

	# Mandatory file
	if (not defined $expression_matrix) {
		die "Missing expression-matrix\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $expression_matrix = shift @$args;

	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;

	log_msg ":: Attempting to remove $expression_matrix ...";
	$self->deletedb($expression_matrix);
	log_msg ":: Done!";
}

__END__

=head1 SYNOPSIS

 sandy expression remove <expression-matrix>

 Arguments:
  an expression-matrix entry

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Remove an expression-matrix from database.

=cut
