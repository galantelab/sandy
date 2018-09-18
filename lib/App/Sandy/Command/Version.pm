package App::Sandy::Command::Version;
# ABSTRACT: version command class. Print version

use App::Sandy::Base 'class';
use Pod::Usage;

extends 'App::Sandy::CLI::Command';

our $VERSION = '0.21'; # VERSION

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	pod2usage(-verbose => 99, -sections => ['NAME', 'VERSION', 'AUTHOR', 'COPYRIGHT AND LICENSE'], -exitval => 0);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Version - version command class. Print version

=head1 VERSION

version 0.21

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
