package App::Sandy::Command::Expression::Dump;
# ABSTRACT: expression subcommand class. Dump an expression-matrix from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Expression';

our $VERSION = '0.22'; # VERSION

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

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Expression::Dump - expression subcommand class. Dump an expression-matrix from database.

=head1 VERSION

version 0.22

=head1 SYNOPSIS

 sandy expression dump <expression-matrix>

 Arguments:
  an expression-matrix entry

 Options:
  -h, --help               brief help message
  -u, --man                full documentation

=head1 DESCRIPTION

Dump an expression-matrix from database.

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
