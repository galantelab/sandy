package App::Sandy::CLI::Command;
# ABSTRACT: App::Sandy::CLI subclass for commands interface

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI';

our $VERSION = '0.21'; # VERSION

override 'opt_spec' => sub {
	super
};

sub validate_args {
	# It needs to be override
}

sub validate_opts {
	# It needs to be override
}

sub execute {
	# It needs to be override
}

sub fill_opts {
	my ($self, $opts, $default_opt) = @_;
	if (ref $opts ne 'HASH' || ref $default_opt ne 'HASH') {
		die '$opts and $default_opt need to be a hash reference';
	}

	for my $opt (keys %$default_opt) {
		$opts->{$opt} = $default_opt->{$opt} if not exists $opts->{$opt};
	}
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::CLI::Command - App::Sandy::CLI subclass for commands interface

=head1 VERSION

version 0.21

=head1 SYNOPSIS

 extends 'App::Sandy::CLI::Command';

=head1 DESCRIPTION

This is the base interface to command classes.
Command classes need to override C<validate_args>,
C<validate_opts> and C<execute> methods

=head1 METHODS

=head2 validate_args

This method receives a reference to C<$args> in void
context. It is expected that the user override it and
validate the arguments

 sub validate_args {
 	my ($self, $args) = @_
	...
 }

=head2 validate_opts

This method receives a reference to C<$opts> in void
context. It is expected that the user override it and
validate the options

 sub validate_opts {
 	my ($self, $opts) = @_;
	...
 }

=head2 fill_opts

This method fills the C<$opts> with default values
passed by the user. it expects two hash refs

 $self->fill_opts($opts, \%default_opts);

=head2 execute

This method is called by the application class. It is
where all the magic occurs. It receives two hash refs
with C<$opts> and C<$args> in void context

 sub execute {
 	my ($self, $opts, $args) = @_;
	...
 }

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
