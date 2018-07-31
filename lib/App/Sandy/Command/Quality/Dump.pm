package App::Sandy::Command::Quality::Dump;
# ABSTRACT: quality subcommand class. Dump a quality profile from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Quality';

# VERSION

sub validate_args {
	my ($self, $args) = @_;
	my $quality_profile = shift @$args;

	if (not defined $quality_profile) {
		die "Missing quality-profile\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $quality_profile = shift @$args;

	my ($matrix, $deepth, $partil) = $self->retrievedb($quality_profile);

	for (my $line = 0; $line < $deepth; $line++) {
		for (my $col = 0; $col < $partil; $col++) {
			print "$matrix->[$col][$line]";
		}
		print "\n";
	}
}

__END__

=head1 SYNOPSIS

 sandy quality dump <quality-profile>

 Arguments:
  a quality-profile entry

 Options:
  -h, --help               brief help message
  -M, --man                full documentation

=head1 DESCRIPTION

Dump a quality profile from database.

=cut
