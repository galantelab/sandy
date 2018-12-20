package App::Sandy::Command::Citation;
# ABSTRACT: citation command class. Print citation

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::Command';

our $VERSION = '0.22'; # VERSION

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	print <<'EOP';
You can cite all versions by using the following DOI:

  Thiago Miller. (2018, May 6).
  galantelab/sandy: A straightforward and complete next-generation sequencing read simulator.
  Zenodo. http://doi.org/10.5281/zenodo.1241587

  BibTeX:

  @misc{thiago_miller_sandy,
    author = {Thiago Miller},
    title  = {galantelab/sandy: A straightforward and complete next-generation sequencing read simulator},
    month  = may,
    year   = 2018,
    doi    = {10.5281/zenodo.1241587},
    url    = {https://doi.org/10.5281/zenodo.1241587}
  }

This DOI represents all versions, and will always resolve to the latest one.
If you want to cite a specific version, please point to https://zenodo.org/record/1241587

EOP
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Citation - citation command class. Print citation

=head1 VERSION

version 0.22

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
