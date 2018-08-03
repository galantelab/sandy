package App::Sandy::Role::Counter;
# ABSTRACT: Bayes counter

use App::Sandy::Base 'role';

# VERSION

sub with_make_counter {
	# ALgorithm based in perlfaq:
	# How do I select a random line from a file?
	# "The Art of Computer Programming"

	my ($self, $num, $picks) = @_;
	return sub {
		state $count_down = $num;
		state $picks_left = $picks;

		my $rc = 0;
		my $rand = int(rand($count_down));

		if ($rand < $picks_left) {
			$rc = 1;
			$picks_left--;
		}

		$count_down--;
		return $rc;
	};
}
