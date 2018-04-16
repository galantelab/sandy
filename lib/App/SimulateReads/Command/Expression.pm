package App::SimulateReads::Command::Expression;
# ABSTRACT: expression command class. Manage expression-matrix database.

use App::SimulateReads::Base 'class';
use App::SimulateReads::DB::Handle::Expression;

extends 'App::SimulateReads::CLI::Command';

our $VERSION = '0.16'; # VERSION

has 'db' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::DB::Handle::Expression',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report/]
);

sub _build_db {
	return App::SimulateReads::DB::Handle::Expression->new;
}

override 'opt_spec' => sub {
	super
};

sub subcommand_map {
	add     => 'App::SimulateReads::Command::Expression::Add',
	remove  => 'App::SimulateReads::Command::Expression::Remove',
	restore => 'App::SimulateReads::Command::Expression::Restore'
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

	my $format = "\t%*s\t%*s\t%*s\t%*s\n";	
	my ($s1, $s2, $s3, $s4) = map {length} qw/expression-matrix/x4;

	printf $format => $s1, "expression-matrix", $s2, "source", $s3, "provider", $s4, "date";
	for my $expression_matrix (sort keys %$report_ref) {
		my $attr = $report_ref->{$expression_matrix};
		printf $format => $s1, $expression_matrix, $s2, $attr->{source}, $s3, $attr->{provider}, $s4, $attr->{date};
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Command::Expression - expression command class. Manage expression-matrix database.

=head1 VERSION

version 0.16

=head1 SYNOPSIS

 simulate_reads expression
 simulate_reads expression [options]
 simulate_reads expression <command>

 Manage expression-matrix database

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Commands:
  add                      add a new expression-matrix to database
  remove                   remove an user expression-matrix from database
  restore                  restore the database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
