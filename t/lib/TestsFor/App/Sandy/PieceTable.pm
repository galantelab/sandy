package TestsFor::App::Sandy::PieceTable;
# ABSTRACT: Tests for 'App::Sandy::PieceTable' class

use App::Sandy::Base 'test';
use Data::Dumper;
use base 'TestsFor';

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;

	my $class = ref $test;
	$class->mk_classdata('default_attr');
	$class->mk_classdata('default_seq');
	$class->mk_classdata('default_table');
}

sub setup : Tests(setup) {
	my $test = shift;
	$test->SUPER::setup;

	my $seq = "A large span of text";
	my %default_attr = (orig => \$seq);

	$test->default_seq(\$seq);
	$test->default_attr(\%default_attr);
	$test->default_table($test->class_to_test->new(%default_attr));
}

sub constructor : Tests(2) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $table = $test->default_table;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $table, $attr;
		is $table->$attr, $value,"The value for $attr shold be correct";
	}
}

sub delete : Test(4) {
	my $test = shift;

	my $table = $test->default_table;
	my $seq = $test->default_seq;

	# Try to remove "large "
	$table->delete(2, 6);
#	diag Dumper($table->piece_table);

	my @pieces = (
		{ pos => 0, len => 2  },
		{ pos => 8, len => 12 }
	);

	my $piece_table = $table->piece_table;

	for (my $i = 0; $i < @pieces; $i++) {
		is $pieces[$i]{pos}, $piece_table->[$i]{pos},
			"table[$i]: pos should be equal to $pieces[$i]{pos}";
		is $pieces[$i]{len}, $piece_table->[$i]{len},
			"table[$i]: len should be equal to $pieces[$i]{len}";
	}
}

sub insert : Test(6) {
	my $test = shift;

	my $table = $test->default_table;
	my $seq = $test->default_seq;

	# Try to insert 'English'
	my $add = "English ";
	$table->insert(\$add, 16);
#	diag Dumper($table->piece_table);

	my @pieces = (
		{ pos => 0,  len => 16 },
		{ pos => 16, len => 8  },
		{ pos => 16, len => 4  }
	);

	my $piece_table = $table->piece_table;

	for (my $i = 0; $i < @pieces; $i++) {
		is $pieces[$i]{pos}, $piece_table->[$i]{pos},
			"table[$i]: pos should be equal to $pieces[$i]{pos}";
		is $pieces[$i]{len}, $piece_table->[$i]{len},
			"table[$i]: len should be equal to $pieces[$i]{len}";
	}
}

sub delete_and_insert : Test(8) {
	my $test = shift;

	my $table = $test->default_table;
	my $seq = $test->default_seq;

	# Try to remove "large "
	$table->delete(2, 6);

	# Try to insert 'English'
	my $add = "English ";
	$table->insert(\$add, 16);

#	diag Dumper($table->piece_table);

	my @pieces = (
		{ pos => 0,  len => 2  },
		{ pos => 8,  len => 8  },
		{ pos => 16, len => 8  },
		{ pos => 16, len => 4  }
	);

	my $piece_table = $table->piece_table;

	for (my $i = 0; $i < @pieces; $i++) {
		is $pieces[$i]{pos}, $piece_table->[$i]{pos},
			"table[$i]: pos should be equal to $pieces[$i]{pos}";
		is $pieces[$i]{len}, $piece_table->[$i]{len},
			"table[$i]: len should be equal to $pieces[$i]{len}";
	}
}

sub lookup : Test(5) {
	my $test = shift;

	my $table = $test->default_table;
	my $seq = $test->default_seq;

	# Try to remove "large "
	$table->delete(2, 6);

	# Try to insert 'English'
	my $add = "English ";
	$table->insert(\$add, 16);

	# I cannot forget to initialize the
	# logical offsets for the lookup method
	# to work
	$table->calculate_logical_offset;

	# Look for the pieces between 16 - 28:
	# "English text"
	my $pieces = $table->lookup(16, 12);

	is scalar(@$pieces), 2,
		"lookup returned the right number of pieces";

	my @pieces = (
		{ pos => 16, len => 8  },
		{ pos => 16, len => 4  }
	);

	for (my $i = 0; $i < @pieces; $i++) {
		is $pieces[$i]{pos}, $pieces->[$i]{pos},
			"table[$i]: pos should be equal to $pieces[$i]{pos}";
		is $pieces[$i]{len}, $pieces->[$i]{len},
			"table[$i]: len should be equal to $pieces[$i]{len}";
	}
}

sub change : Test(6) {
	my $test = shift;

	my $table = $test->default_table;
	my $seq = $test->default_seq;

	# Try to change "large " to "ponga "
	my $to_remove = "large ";
	my $change = "ponga ";
	$table->change(\$change, 2, length $to_remove);
#	diag Dumper($table->piece_table);

	my @pieces = (
		{ pos => 0, len => 2  },
		{ pos => 2, len => 6  },
		{ pos => 8, len => 12 }
	);

	my $piece_table = $table->piece_table;

	for (my $i = 0; $i < @pieces; $i++) {
		is $pieces[$i]{pos}, $piece_table->[$i]{pos},
			"table[$i]: pos should be equal to $pieces[$i]{pos}";
		is $pieces[$i]{len}, $piece_table->[$i]{len},
			"table[$i]: len should be equal to $pieces[$i]{len}";
	}
}
