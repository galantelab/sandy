package App::Sandy::Command::Variation::Dump;
# ABSTRACT: variation subcommand class. Dump structural variation from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

our $VERSION = '0.21'; # VERSION

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

	my $variation = $self->retrievedb($args);
	print "#seqid\tposition\tid\treference\talteration\tgenotype\n";

	for my $id (sort keys %$variation) {
		my $data = $variation->{$id};
		for my $entry (@$data) {
			print "$entry->{seq_id}\t$entry->{pos}\t$entry->{id}\t$entry->{ref}\t$entry->{alt}\t$entry->{plo}\n";
		}
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Variation::Dump - variation subcommand class. Dump structural variation from database.

=head1 VERSION

version 0.21

=head1 SYNOPSIS

 sandy variation dump <structural variation>

 Arguments:
  a structural variation entry

 Options:
  -h, --help               brief help message
  -u, --man                full documentation

=head1 DESCRIPTION

Dump structural variation from database.

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
