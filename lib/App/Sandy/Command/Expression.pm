package App::Sandy::Command::Expression;
# ABSTRACT: expression command class. Manage expression-matrix database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Expression;
use Text::ASCIITable;

extends 'App::Sandy::CLI::Command';

# VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Expression',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report retrievedb/]
);

sub _build_db {
	return App::Sandy::DB::Handle::Expression->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::Sandy::Command::Expression::Add',
	remove  => 'App::Sandy::Command::Expression::Remove',
	restore => 'App::Sandy::Command::Expression::Restore',
	dump    => 'App::Sandy::Command::Expression::Dump'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;

	if (%$report_ref) {
		my $t1 = Text::ASCIITable->new;
		$t1->setCols('expression-matrix', 'source', 'provider', 'date');

		for my $expression_matrix (sort keys %$report_ref) {
			my $attr = $report_ref->{$expression_matrix};
			$t1->addRow($expression_matrix, $attr->{source}, $attr->{provider}, $attr->{date});
		}

		print $t1;
	}
}

__END__

=head1 SYNOPSIS

 sandy expression
 sandy expression [options]
 sandy expression <command>

 Options:
  -h, --help               brief help message
  -u, --man                full documentation
 
 Commands:
  add                      add a new expression-matrix to database
  dump                     dump an expression-matrix from database
  remove                   remove an user expression-matrix from database
  restore                  restore the database

=head1 DESCRIPTION

Manage expression-matrix database.

=cut
