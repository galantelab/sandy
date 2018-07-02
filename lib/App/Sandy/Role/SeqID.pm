package App::Sandy::Role::SeqID;
# ABSTRACT: Role for seqid standardization

use App::Sandy::Base 'role';

# VERSION

my $SEQID_REGEX = qr/^
	(?:chr|ref)?
	(\d{1,2}|[XY]|MT?)
$/iax;

sub with_std_seqid {
	my ($self, $seqid) = @_;

	croak "No seqid defined" if not defined $seqid;

	return $seqid =~ $SEQID_REGEX ?
		uc $1 =~ s/T$//ir :
		$seqid;
}
