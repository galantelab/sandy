package App::Sandy::Role::SeqID;
# ABSTRACT: Role for seqid standardization

use App::Sandy::Base 'role';

# VERSION

my $SEQID_REGEX = qr/^chr(?=\w+$)/ia;
my $MT_REGEX = qr/^MT$/ia;

sub with_std_seqid {
	my ($self, $seqid) = @_;

	croak "No seqid defined" if not defined $seqid;

	$seqid =~ s/$SEQID_REGEX//;
	$seqid =~ s/$MT_REGEX/M/;

	return uc $seqid;
}
