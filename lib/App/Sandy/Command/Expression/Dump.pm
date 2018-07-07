package App::Sandy::Command::Expression::Dump;
# ABSTRACT: expression subcommand class. Dump an expression-matrix from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Expression';

# VERSION

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

	my $matrix = $self->retrievedb($expression_matrix);
	print "#feature\tcount\n";

	for my $feature (sort keys %$matrix) {
		print "$feature\t$matrix->{$feature}\n";
	}
}

__END__

=head1 SYNOPSIS

 sandy expression dump <expression-matrix>

 Arguments:
  an expression-matrix entry

 Options:
  -h, --help               brief help message
  -M, --man                full documentation

=head1 DESCRIPTION

Dump an expression-matrix from database.

=cut
