package App::Sandy::Role::RunTimeTemplate;
# ABSTRACT: Extends class with runtime printf like function

use App::Sandy::Base 'role';

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
