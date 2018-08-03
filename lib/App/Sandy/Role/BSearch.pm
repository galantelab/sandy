package App::Sandy::Role::BSearch;
# ABSTRACT: Binary search role

use App::Sandy::Base 'role';

# VERSION

sub with_bsearch {
	my ($self, $key, $base, $nmemb, $func) = @_;
	return $self->_bsearch($key, $base, 0, $nmemb - 1, $func);
}

sub _bsearch {
	my ($self, $key1, $base, $start, $end, $func) = @_;

	if ($start > $end) {
		# Not found!
		return;
	}

	my $index = int(($start + $end) / 2);
	my $key2 = $base->[$index];

	# $key1 <=> $key2
	my $rc = $func->($key1, $key2);

	if ($rc > 0) {
		return $self->_bsearch($key1, $base, $index + 1, $end, $func);
	} elsif ($rc < 0) {
		return $self->_bsearch($key1, $base, $start, $index - 1, $func);
	} else {
		return $index;
	}
}
