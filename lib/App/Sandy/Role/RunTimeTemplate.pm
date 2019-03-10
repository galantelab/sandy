package App::Sandy::Role::RunTimeTemplate;
# ABSTRACT: Extends class with runtime printf like function

use App::Sandy::Base 'role';

our $VERSION = '0.23'; # VERSION

sub with_compile_template {
	my ($self, $template, $input_name, $sym_table) = @_;
	croak "sym_table is not a hashref" unless ref $sym_table eq 'HASH';

	# Inactivate perl reserved characters $, @, &, #
	$template =~ s/(?<!\\)[\$\@\#\&]/\\$&/g;

	while (my ($sym, $variable) = each %$sym_table) {
		$template =~ s/$sym/$variable/g;
	}

	## no critic

	my $sub = eval "sub { my \$$input_name = shift; return \"$template\"; }";
	die "Error compiling template '$template': $@" if $@;

	## use critic

	return $sub;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::RunTimeTemplate - Extends class with runtime printf like function

=head1 VERSION

version 0.23

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

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

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
