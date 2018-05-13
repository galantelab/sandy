package App::Sandy::BTree::Interval;
# ABSTRACT: AVL Interval Binary Tree

use App::Sandy::Base 'class';
use App::Sandy::BTree::Interval::Node;

# Needed to avoid annoying warnnings
use warnings;
no warnings 'recursion';

# VERSION

has 'root' => (
	is        => 'rw',
	isa       => 'Maybe[App::Sandy::BTree::Interval::Node]',
	required  => 0
);

sub _max_height {
	my ($self, $n1, $n2) = @_;

	my $h1 = defined $n1
		? $n1->height
		: 0;

	my $h2  = defined $n2
		? $n2->height
		: 0;

	return $h1 > $h2 ? $h1 : $h2;
}

sub _right_rotate {
	my ($self, $y) = @_;

	my $x = $y->left;
	my $T2 = $x->right;

	# Perform rotation
	$x->right($y);
	$y->left($T2);

	# Update heights
	$y->height($self->_max_height($y->left, $y->right) + 1);
	$x->height($self->_max_height($x->left, $x->right) + 1);

	# Update max
	$x->max($y->max);
	$y->max($self->_max_high_node($y));

	# Return new root
	return $x;
}

sub _left_rotate {
	my ($self, $x) = @_;

	my $y = $x->right;
	my $T2 = $y->left;

	# Perform rotation
	$y->left($x);
	$x->right($T2);

	# Update heights
	$x->height($self->_max_height($x->left, $x->right) + 1);
	$y->height($self->_max_height($y->left, $y->right) + 1);

	# Update max
	$y->max($x->max);
	$x->max($self->_max_high_node($x));

	# Return new root
	return $y;
}

sub _balance_factor {
	my ($self, $node) = @_;

	if (not defined $node) {
		return 0;
	}

	my $h1 = defined $node->left
		? $node->left->height
		: 0;

	my $h2  = defined $node->right
		? $node->right->height
		: 0;

	return $h1 - $h2;
}

sub insert {
	my ($self, $low, $high, $data) = @_;

	if ($low > $high) {
		croak "low value ($low) greater then high value ($high)";
	}

	my $node = App::Sandy::BTree::Interval::Node->new(
		low  => $low,
		high => $high,
		data => $data
	);

	$self->root($self->_insert($self->root, $node));
}

sub _insert {
	my ($self, $root, $node) = @_;

	if (not defined $root) {
		return $node;
	}

	if ($node->low < $root->low) {
		$root->left($self->_insert($root->left, $node));
	} else {
		$root->right($self->_insert($root->right, $node));
	}

	if ($root->max < $node->high) {
		$root->max($node->high);
	}

	#  Update height of this ancestor node
	$root->height($self->_max_height($root->left, $root->right) + 1);

	# Get the balance factor of this ancestor
	# node to check whether this node became
	# unbalance
	my $balance = $self->_balance_factor($root);

	# Left left case
	if ($balance > 1 && $node->low < $root->left->low) {
		return $self->_right_rotate($root);
	}

	# right right case
	if ($balance < -1 && $node->low > $root->right->low) {
		return $self->_left_rotate($root);
	}

	# Left right case
	if ($balance > 1 && $node->low > $root->left->low) {
		$root->left($self->_left_rotate($root->left));
		return $self->_right_rotate($root);
	}

	# Right left case
	if ($balance < -1 && $node->low < $root->right->low) {
		$root->right($self->_right_rotate($root->right));
		return $self->_left_rotate($root);
	}

	# return the (unchanged) node pointer
	return $root;
}

sub preorder {
	my ($self, $code) = @_;

	if (ref $code ne 'CODE') {
		croak "preorder needes a 'CODE' as parameter";
	}

	$self->_preorder($self->root, $code);
}

sub _preorder {
	my ($self, $root, $code) = @_;

	if ($root) {
		$code->($root);
		$self->_preorder($root->left, $code);
		$self->_preorder($root->right, $code);
	}
}

sub _do_overlap {
	my ($self, $node, $low, $high) = @_;
	return $node->low <= $high && $low <= $node->high
		? 1
		: 0;
}

sub search {
	my ($self, $low, $high) = @_;

	if ($low > $high) {
		croak "low value ($low) greater then high value ($high)";
	}

	my @datas;

	$self->_search($self->root, $low, $high, \@datas);

	return wantarray
		? @datas
		: \@datas;
}

sub _search {
	my ($self, $root, $low, $high, $datas_a) = @_;

	if (not defined $root) {
		return;
	}

	# If left child of root is present and max of left child is
	# greater than or equal to given interval, then i may
	# overlap with an interval is left subtree
	if ($root->left && $root->left->max >= $low) {
		$self->_search($root->left, $low, $high, $datas_a);
	}

	# If given interval overlaps with root
	if ($self->_do_overlap($root, $low, $high)) {
		push @$datas_a => $root->data;
	}

	# Else interval can only overlap with right subtree
	$self->_search($root->right, $low, $high, $datas_a);
}

sub inorder {
	my ($self, $code) = @_;

	if (ref $code ne 'CODE') {
		croak "inorder needes a 'CODE' as parameter";
	}

	$self->_inorder($self->root, $code);
}

sub _inorder {
	my ($self, $root, $code) = @_;

	if ($root) {
		$self->_inorder($root->left, $code);
		$code->($root);
		$self->_inorder($root->right, $code);
	}
}

sub _min_low_node {
	my ($self, $node) = @_;

	my $current = $node;

	while ($current->left) {
		$current = $current->left;
	}

	return $current;
}

sub _max_high_node {
	my ($self, $node) = @_;

	my $max = 0;

	if (defined $node->left && defined $node->right) {
		$max = $node->left->max > $node->right->max
			? ($node->left->max > $node->high
				? node->left->max
				: $node->high)
			: ($node->right->max > $node->high
				? $node->right->max
				: $node->high);
	} elsif (defined $node->left) {
		$max = $node->left->max > $node->high
			? $node->left->max
			: $node->high;
	} elsif (defined $node->right) {
		$max = $node->right->max > $node->high
			? $node->right->max
			: $node->high;
	} else {
		$max = $node->high;
	}

	return $max;
}

sub delete {
	my ($self, $low, $high) = @_;

	if ($low > $high) {
		croak "low value ($low) greater then high value ($high)";
	}

	my $data;

	$self->root($self->_delete($self->root, $low, $high, \$data));

	return $data;
}

sub _delete {
	my ($self, $root, $low, $high, $data) = @_;

	if (not defined $root) {
		return;
	}

	# If the low to be deleted is smaller than the
	# root's low, then it lies in left subtree
	if ($low < $root->low) {
		$root->left($self->_delete($root->left, $low, $high, $data));

	# If the low to be deleted is greater than the
	# root's low, then it lies in right subtree
	} elsif ($low > $root->low) {
		$root->right($self->_delete($root->right, $low, $high, $data));

	# if low is same as root's low, then test if it matches
	} else {
		# Does it matches?
		if ($high == $root->high) {
			$$data = $root->data if defined $data;

			# node with only one child or no child
			if (not defined $root->left) {
				return $root->right;
			} elsif (not defined $root->right) {
				return $root->left;
			}

			# node with both children. Get the inorder successor
			# (smallest in the right subtree)
			my $temp = $self->_min_low_node($root->right);

			# Copy the inorder successor's content to this node
			$root->low($temp->low);
			$root->high($temp->high);
			$root->data($temp->data);

			# Delete the inorder successor
			$root->right($self->_delete($root->right, $temp->low, $temp->high));

		# If not, then try to the right node
		} else {
			$root->right($self->_delete($root->right, $low, $high, $data));
		}
	}

	# Update the max tracker
	$root->max($self->_max_high_node($root));

	# Update the height of current node
	$root->height($self->_max_height($root->left, $root->right) + 1);

	# check whether this node became unbalanced)
	my $balance = $self->_balance_factor($root);

	# Left Left Case
	if ($balance > 1 && $self->_balance_factor($root->left) >= 0) {
		return $self->_right_rotate($root);
	}

	# Left Right Case
	if ($balance > 1 && $self->_balance_factor($root->left) < 0) {
		$root->left($self->_left_rotate($root->left));
		return $self->_right_rotate($root);
	}

	# Right Right Case
	if ($balance < -1 && $self->_balance_factor($root->right) <= 0) {
		return $self->_left_rotate($root);
	}

	# Right Left Case
	if ($balance < -1 && $self->_balance_factor($root->right) > 0) {
		$root->right($self->_right_rotate($root->right));
		return $self->_left_rotate($root);
	}

	return $root;
}

sub postorder {
	my ($self, $code) = @_;

	if (ref $code ne 'CODE') {
		croak "postorder needes a 'CODE' as parameter";
	}

	$self->_postorder($self->root, $code);
}

sub _postorder {
	my ($self, $root, $code) = @_;

	if ($root) {
		$self->_postorder($root->left, $code);
		$self->_postorder($root->right, $code);
		$code->($root);
	}
}
