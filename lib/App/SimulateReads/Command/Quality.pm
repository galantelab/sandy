package App::SimulateReads::Command::Quality;
# ABSTRACT: quality command class. Manage quality profile database.

use App::SimulateReads::Base 'class';
use App::SimulateReads::DB::Handle::Quality;

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
	return $self->_print_report;
}

sub _print_report {
	my $self = shift;
	my $report_ref = $self->make_report;
	return if not defined $report_ref;

	my $format = "\t%*s\t%*s\t%*s\t%*s\t%*s\n";
	my ($s1, $s2, $s3, $s4, $s5) = map {length} qw/sequencing_system/x5;
	printf $format => $s1, "quality profile", $s2, "size", $s3, "source", $s4, "provider", $s5, "date";

	for my $quality_profile (sort keys %$report_ref) {
		my $attr = $report_ref->{$quality_profile};
		printf $format => $s1, $quality_profile, $s2, $attr->{size}, $s3, $attr->{source}, $s4, $attr->{provider}, $s5, $attr->{date};
	}
}

__END__

=head1 SYNOPSIS

 simulate_reads quality
 simulate_reads quality [options]
 simulate_reads quality <command>

 Manage quality profile database

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new quality profile to database
  remove                   remove an user quality profle from database
  restore                  restore the database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=cut
