package App::Sandy::DB::Handle::Variation;
# ABSTRACT: Class to handle structural variation database schemas.

use App::Sandy::Base 'class';
use App::Sandy::DB;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;
use Scalar::Util qw/looks_like_number refaddr/;
use List::Util 'max';

with 'App::Sandy::Role::IO';

# VERSION

sub insertdb {
	my ($self, $file, $name, $source, $is_user_provided) = @_;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Checking if there is already a structural variation '$name' ...";
	my $rs = $schema->resultset('StructuralVariation')->find({ name => $name });
	if ($rs) {
		die "There is already a structural variation '$name'\n";
	} else {
		log_msg ":: structural variation '$name' not found";
	}

	log_msg ":: Indexing '$file' ...";
	my $indexed_file = $self->_index_snv($file);

	log_msg ":: Removing overlapping entries in structural variation file '$file', if any ...";
	$self->_validate_indexed_snv($indexed_file);

	log_msg ":: Converting data to bytes ...";
	my $bytes = nfreeze $indexed_file;
	log_msg ":: Compressing bytes ...";
	gzip \$bytes => \my $compressed;

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	log_msg ":: Storing structural variation '$name'...";
	$rs = $schema->resultset('StructuralVariation')->create({
		name             => $name,
		source           => $source,
		is_user_provided => $is_user_provided,
		matrix           => $compressed
	});

	# End transation
	$guard->commit;
}

sub _index_snv {
	my ($self, $snv_file) = @_;
	my $fh = $self->with_open_r($snv_file);

	my %indexed_snv;
	my $line = 0;

	# chr pos ref @obs he
	while (<$fh>) {
		$line++;

		# Skip coments and blank lines
		next if /^#/;
		next if /^\s*$/;

		chomp;
		my @fields = split;

		die "Not found all fields (SEQID, POSITION, ID, REFERENCE, OBSERVED, PLOIDY) into file '$snv_file' at line $line\n"
			unless scalar @fields >= 6;

		die "Second column, position, does not seem to be a number into file '$snv_file' at line $line\n"
			unless looks_like_number($fields[1]);

		die "Second column, position, has a value lesser or equal to zero into file '$snv_file' at line $line\n"
			if $fields[1] <= 0;

		die "Fourth column, reference, does not seem to be a valid entry: '$fields[3]' into file '$snv_file' at line $line\n"
			unless $fields[3] =~ /^(\w+|-)$/;

		die "Fifth column, alteration, does not seem to be a valid entry: '$fields[4]' into file '$snv_file' at line $line\n"
			unless $fields[4] =~ /^(\w+|-)$/;

		die "Sixth column, ploidy, has an invalid entry: '$fields[5]' into file '$snv_file' at line $line. Valid ones are 'HE' or 'HO'\n"
			unless $fields[5] =~ /^(HE|HO)$/;

		if ($fields[3] eq $fields[4]) {
			warn "There is an alteration equal to the reference at '$snv_file' line $line. I will ignore it\n";
			next;
		}

		# Sequence inside perl begins at 0
		my $position = int($fields[1] - 1);

		# Compare the alterations and reference to guess the max variation on sequence
		my $size_of_variation = max map { length } $fields[3], $fields[4];
		my $high = $position + $size_of_variation - 1;

		my %variation = (
			id   => $fields[2],
			ref  => $fields[3],
			alt  => $fields[4],
			plo  => $fields[5],
			pos  => $position,
			low  => $position,
			high => $high,
			line => $line
		);

		push @{ $indexed_snv{$fields[0]} } => \%variation;
	}

	close $fh
		or die "Cannot close snv file '$snv_file': $!\n";

	return \%indexed_snv;
}

sub _validate_indexed_snv {
	my ($self, $indexed_snv) = @_;

	for my $seq_id (keys %$indexed_snv) {
		my $snvs_a = delete $indexed_snv->{$seq_id};
		my @sorted_snvs = sort { $a->{low} <=> $b->{low} } @$snvs_a;

		my $prev_snv = $sorted_snvs[0];
		my $high = $prev_snv->{high};
		push my @snv_cluster => $prev_snv;

		for (my $i = 1; $i < @sorted_snvs; $i++) {
			my $next_snv = $sorted_snvs[$i];

			# If not overlapping
			if ($next_snv->{low} > $high) {
				my $valid_snvs = $self->_validate_indexed_snv_cluster($seq_id, \@snv_cluster);
				push @{ $indexed_snv->{$seq_id} } => @$valid_snvs;
				@snv_cluster = ();
			}

			push @snv_cluster => $next_snv;
			$high = max $high, $next_snv->{high};
			$prev_snv = $next_snv;
		}

		my $valid_snvs = $self->_validate_indexed_snv_cluster($seq_id, \@snv_cluster);
		push @{ $indexed_snv->{$seq_id} } => @$valid_snvs;
	}
}

sub _validate_indexed_snv_cluster {
	my ($self, $seq_id, $snvs) = @_;
	my $snv_file = $self->snv_file;

	# My rules:
	# The biggest structural variation gains precedence.
	# If occurs an overlapping, I search to the biggest variation among
	# the saved alterations and compare it with the actual entry:
	#    *** Remove all overlapping variations if actual entry is bigger;
	#    *** Skip actual entry if it is lower than the biggest variation
	#    *** Insertionw can be before any alterations

	my @saved_snvs;
	my %blacklist;

	OUTER: for (my $i = 0; $i < @$snvs; $i++) {
		my $prev_snv = $snvs->[$i];

		if ($blacklist{refaddr($prev_snv)}) {
			next OUTER;
		}

		INNER: for (my $j = 0; $j < @$snvs; $j++) {
			my $next_snv = $snvs->[$j];

			if (($i == $j) || $blacklist{refaddr($next_snv)}) {
				next INNER;
			}

			# Insertion after insertion
			if ($next_snv->{ref} eq '-' && $prev_snv->{ref} eq '-' && $next_snv->{pos} != $prev_snv->{pos}) {
				next INNER;

			# Insertion before alteration
			} elsif ($next_snv->{ref} eq '-' && $prev_snv->{ref} ne '-' && $next_snv->{pos} < $prev_snv->{pos}) {
				next INNER;

			# In this case, it gains the biggest one
			} else {
				my $prev_size = $prev_snv->{high} - $prev_snv->{low} + 1;
				my $next_size = $next_snv->{high} - $next_snv->{low} + 1;

				if ($prev_size >= $next_size) {
					log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s] at '%s' line %d\n"
						=> $seq_id, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_snv->{ref}, $prev_snv->{alt}, $prev_snv->{plo},
						$seq_id, $next_snv->{pos}+1, $next_snv->{id}, $next_snv->{ref}, $next_snv->{alt}, $next_snv->{plo},
						$snv_file, $next_snv->{line};

					$blacklist{refaddr($next_snv)} = 1;
					next INNER;
				} else {
					log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s] at '%s' line %d\n"
						=> $seq_id, $next_snv->{pos}+1, $next_snv->{id}, $next_snv->{ref}, $next_snv->{alt}, $next_snv->{plo},
						$seq_id, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_snv->{ref}, $prev_snv->{alt}, $prev_snv->{plo},
						$snv_file, $prev_snv->{line};

					$blacklist{refaddr($prev_snv)} = 1;
					next OUTER;
				}
			}
		}

		push @saved_snvs => $prev_snv;
	}

	return \@saved_snvs;
}

sub retrievedb {
	my ($self, $structural_variation) = @_;
	my $schema = App::Sandy::DB->schema;

	my $rs = $schema->resultset('StructuralVariation')->find({ name => $structural_variation });
	die "'$structural_variation' not found into database\n" unless defined $rs;

	my $compressed = $rs->matrix;
	die "structural variation entry '$structural_variation' exists, but the related data is missing\n"
		unless defined $compressed;

	gunzip \$compressed => \my $bytes;
	my $matrix = thaw $bytes;
	return $matrix;
}

sub deletedb {
	my ($self, $structural_variation) = @_;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Checking if there is already a structural variation '$structural_variation' ...";
	my $rs = $schema->resultset('StructuralVariation')->find({ name => $structural_variation });
	die "'$structural_variation' not found into database\n" unless defined $rs;

	log_msg ":: Found '$structural_variation'";
	die "'$structural_variation' is not a user provided entry. Cannot be deleted\n"
		unless $rs->is_user_provided;

	log_msg ":: Removing '$structural_variation' entry ...";

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	$rs->delete;

	# End transation
	$guard->commit;
}

sub restoredb {
	my $self = shift;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Searching for user-provided entries ...";
	my $user_provided = $schema->resultset('StructuralVariation')->search(
		{ is_user_provided => 1 }
	);

	my $entry = $user_provided->next;
	if ($entry) {
		log_msg ":: Found:";
		do {
			log_msg '   ==> ' . $entry->name;
		} while ($entry = $user_provided->next);
	} else {
		die "Not found user-provided entries. There is no need to restoring\n";
	}

	log_msg ":: Removing all user-provided entries ...";

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	$user_provided->delete;

	# End transation
	$guard->commit;
}

sub make_report {
	my $self = shift;
	my $schema = App::Sandy::DB->schema;
	my %report;

	my $rs = $schema->resultset('StructuralVariation')->search(undef);

	while (my $structural_variation = $rs->next) {
		my %hash = (
			source   => $structural_variation->source,
			provider => $structural_variation->is_user_provided ? "user" : "vendor",
			date     => $structural_variation->date
		);
		$report{$structural_variation->name} = \%hash;
	}

	return \%report;
}
