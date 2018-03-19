package App::SimulateReads::Role::RunTimeTemplate;
# ABSTRACT: Extends class with runtime printf like function

use App::SimulateReads::Base 'role';

# VERSION

sub compile_template {
	my ($self, $template, $input_name, $sym_table) = @_;
	croak "sym_table is not a hashref" unless ref $sym_table eq 'HASH';

	while (my ($sym, $variable) = each %$sym_table) {
		$template =~ s/$sym/$variable/g;
	}

	my $sub = eval "sub { my \$$input_name = shift; return \"$template\"; }";
	croak "Error compiling template '$template': $@" if $@;

	return $sub;
}
