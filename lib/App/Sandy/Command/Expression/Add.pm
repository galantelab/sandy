package App::Sandy::Command::Expression::Add;
# ABSTRACT: expression subcommand class. Add an expression-matrix to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Expression';

our $VERSION = '0.23'; # VERSION

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'expression-matrix|f=s',
	'source|s=s'
};

sub _default_opt {
	'verbose' => 0,
	'source'  => 'not defined'
}

sub validate_args {
	my ($self, $args) = @_;
	my $file = shift @$args;

	# Mandatory file
	if (not defined $file) {
		die "Missing an expression-matrix file\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "'$file' is not a file. Please, give me a valid expression-matrix file\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	if (not exists $opts->{'expression-matrix'}) {
		die "Mandatory option 'expression-matrix' not defined\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $file = shift @$args;

	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Go go go
	log_msg ":: Inserting $opts->{'expression-matrix'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'expression-matrix'},
		$opts->{'source'},
		1
	);

	log_msg ":: Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Expression::Add - expression subcommand class. Add an expression-matrix to the database.

=head1 VERSION

version 0.23

=head1 SYNOPSIS

 sandy expression add -f <entry name> [-s <source>] FILE

 Arguments:
  an expression-matrix file

 Mandatory options:
  -f, --expression-matrix    an expression-matrix name

 Options:
  -h, --help                 brief help message
  -u, --man                  full documentation
  -v, --verbose              print log messages
  -s, --source               expression-matrix source detail for database

=head1 DESCRIPTION

Add an expression-matrix to the database.

=head1 OPTIONS

=over 8

=item B<--expression-matrix>

A valid expression-matrix is a file with 2 columns. The first column is for the seqid
and the second column is for the count. The counts will be treated as weights

=back

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
