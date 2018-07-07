package App::Sandy::Command::Variation;
# ABSTRACT: variation command class. Manage structural variation database.

use App::Sandy::Base 'class';
use App::Sandy::DB::Handle::Variation;
use Text::SimpleTable::AutoWidth;

extends 'App::Sandy::CLI::Command';

# VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::Sandy::DB::Handle::Variation',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report retrievedb/]
);

sub _build_db {
	return App::Sandy::DB::Handle::Variation->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::Sandy::Command::Variation::Add',
	remove  => 'App::Sandy::Command::Variation::Remove',
	restore => 'App::Sandy::Command::Variation::Restore',
	dump    => 'App::Sandy::Command::Variation::Dump'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;

	if (%$report_ref) {
		my $t1 = Text::SimpleTable::AutoWidth->new;

		$t1->captions(['structural variation', 'source', 'provider', 'date']);

		for my $structural_variation (sort keys %$report_ref) {
			my $attr = $report_ref->{$structural_variation};
			$t1->row($structural_variation, $attr->{source}, $attr->{provider}, $attr->{date});
		}

		print $t1->draw;
	}
}

__END__

=head1 SYNOPSIS

 sandy variation
 sandy variation [options]
 sandy variation <command>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new structural variation to database
  dump                     dump structural variation from database
  remove                   remove an user structural variation from database
  restore                  restore the database

=head1 DESCRIPTION

Manage structural variation database.

=cut
