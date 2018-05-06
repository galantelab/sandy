package App::Sandy::Command::Expression;
# ABSTRACT: expression command class. Manage expression-matrix database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Expression;
use Text::SimpleTable::AutoWidth;

extends 'App::Sandy::CLI::Command';

# VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Expression',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report/]
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
	restore => 'App::Sandy::Command::Expression::Restore'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;
	my $t1 = Text::SimpleTable::AutoWidth->new;

	$t1->captions([qw/expression-matrix source provider date/]);

	for my $expression_matrix (sort keys %$report_ref) {
		my $attr = $report_ref->{$expression_matrix};
		$t1->row($expression_matrix, $attr->{source}, $attr->{provider}, $attr->{date});
	}

	print $t1->draw;
}

__END__

=head1 SYNOPSIS

 sandy expression
 sandy expression [options]
 sandy expression <command>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new expression-matrix to database
  remove                   remove an user expression-matrix from database
  restore                  restore the database

=head1 DESCRIPTION

Manage expression-matrix database.

=cut
