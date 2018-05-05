package App::SimulateReads::Command::Quality;
# ABSTRACT: quality command class. Manage quality profile database.

use App::SimulateReads::Base 'class';
use App::SimulateReads::DB::Handle::Quality;
use Text::SimpleTable::AutoWidth;

extends 'App::SimulateReads::CLI::Command';

# VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::DB::Handle::Quality',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report/]
);

sub _build_db {
	return App::SimulateReads::DB::Handle::Quality->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::SimulateReads::Command::Quality::Add',
	remove  => 'App::SimulateReads::Command::Quality::Remove',
	restore => 'App::SimulateReads::Command::Quality::Restore'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;

	my $report_ref = $self->make_report;
	my $t1 = Text::SimpleTable::AutoWidth->new;

	$t1->captions(['quality profile', 'size', 'source', 'provider', 'date']);

	for my $quality_profile (sort keys %$report_ref) {
		my $attr = $report_ref->{$quality_profile};
		$t1->row($quality_profile, $attr->{size}, $attr->{source}, $attr->{provider}, $attr->{date});
	}

	print $t1->draw;
}

__END__

=head1 SYNOPSIS

 simulate_reads quality
 simulate_reads quality [options]
 simulate_reads quality <command>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new quality profile to database
  remove                   remove an user quality profle from database
  restore                  restore the database

=head1 DESCRIPTION

Manage quality profile database.

=cut
