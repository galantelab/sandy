package App::SimulateReads::Role::RunTimeTemplate;
# ABSTRACT: Extends class with runtime printf like function

use App::SimulateReads::Base 'role';

our $VERSION = '0.13'; # VERSION

sub compile_template {
	my ($self, $template, $input_name, $sym_table) = @_;
	croak "sym_table is not a hashref" unless ref $sym_table eq 'HASH';

	while (my ($sym, $variable) = each %$sym_table) {
		$template =~ s/$sym/$variable/g;
	}

	## no critic

	my $sub = eval "sub { my \$$input_name = shift; return \"$template\"; }";
	croak "Error compiling template '$template': $@" if $@;

	## use critic

	return $sub;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Role::RunTimeTemplate - Extends class with runtime printf like function

=head1 VERSION

version 0.13

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
