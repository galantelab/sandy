package App::Sandy::Role::SeqID;
# ABSTRACT: Role for seqid standardization

use App::Sandy::Base 'role';

our $VERSION = '0.23'; # VERSION

my $SEQID_REGEX = qr/^chr(?=\w+$)/ia;
my $MT_REGEX = qr/^MT$/ia;

sub with_std_seqid {
	my ($self, $seqid) = @_;

	croak "No seqid defined" if not defined $seqid;

	$seqid =~ s/$SEQID_REGEX//;
	$seqid =~ s/$MT_REGEX/M/;

	return uc $seqid;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::SeqID - Role for seqid standardization

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
