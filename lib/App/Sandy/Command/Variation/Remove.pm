package App::Sandy::Command::Variation::Remove;
# ABSTRACT: variation subcommand class. Remove structural variation from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

our $VERSION = '0.22'; # VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v'
};

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
	my $structural_variation = shift @$args;

	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;

	log_msg ":: Attempting to remove $structural_variation ...";
	$self->deletedb($structural_variation);
	log_msg ":: Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Variation::Remove - variation subcommand class. Remove structural variation from database.

=head1 VERSION

version 0.22

=head1 SYNOPSIS

 sandy variation remove <structural variation>

 Arguments:
  a structural variation entry

 Options:
  -h, --help               brief help message
  -u, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

Remove structural variation from database.

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
