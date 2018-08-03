package App::Sandy::Command::Variation::Dump;
# ABSTRACT: variation subcommand class. Dump structural variation from database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Variation';

# VERSION

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

	my $variation = $self->retrievedb($args);
	print "#seqid\tposition\tid\treference\talteration\tgenotype\n";

	for my $id (sort keys %$variation) {
		my $data = $variation->{$id};
		for my $entry (@$data) {
			print "$entry->{seq_id}\t$entry->{pos}\t$entry->{id}\t$entry->{ref}\t$entry->{alt}\t$entry->{plo}\n";
		}
	}
}

__END__

=head1 SYNOPSIS

 sandy variation dump <structural variation>

 Arguments:
  a structural variation entry

 Options:
  -h, --help               brief help message
  -u, --man                full documentation

=head1 DESCRIPTION

Dump structural variation from database.

=cut
