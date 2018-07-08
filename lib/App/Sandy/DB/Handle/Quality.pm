package App::Sandy::DB::Handle::Quality;
# ABSTRACT: Class to handle quality database schemas.

use App::Sandy::Base 'class';
use App::Sandy::DB;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;

with 'App::Sandy::Role::IO';

# VERSION

sub insertdb {
	my ($self, $file, $name, $size, $source, $is_user_provided, $type) = @_;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Checking if there is already a quality-profile '$name' ...";
	my $rs = $schema->resultset('QualityProfile')->find({ name => $name });
	if ($rs) {
		die "There is already a quality-profile '$name'\n";
	} else {
		log_msg ":: quality-profile '$name' not found";
	}

	if ($type !~ /^(fastq|raw)$/) {
		die "Unknown indexing type '$type': Valids are 'raw' and 'fastq'\n";
	}

	log_msg ":: Indexing '$file'. It may take several minutes ...";
	my ($arr, $deepth) = $self->_index_quality_type($file, $size, $type);

	log_msg ":: Converting array to bytes ...";
	my $bytes = nfreeze $arr;
	log_msg ":: Compressing bytes ...";
	gzip \$bytes => \my $compressed;

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	log_msg ":: Storing quality matrix entry at '$name' ...";
	$rs = $schema->resultset('QualityProfile')->create({
		name             => $name,
		source           => $source,
		is_user_provided => $is_user_provided,
		size             => $size,
		deepth           => $deepth,
		matrix           => $compressed
	});

	# End transation
	$guard->commit;
}

sub _index_quality {
	my ($self, $quality_ref, $size) = @_;
	my $deepth = scalar @$quality_ref;

	my @arr;
	for (@$quality_ref) {
		my @tmp = split //;
		for (my $i = 0; $i < $size; $i++) {
			push @{ $arr[$i] } => $tmp[$i];
		}
	}

	return (\@arr, $deepth);
}

sub _index_quality_type {
	# ALgorithm based in perlfaq:
	# How do I select a random line from a file?
	# "The Art of Computer Programming"

	my ($self, $file, $size, $type) = @_;
	my $fh = $self->with_open_r($file);

	log_msg ":: Counting number of lines in '$file' ...";
	my $num_lines = $self->_wcl($file);
	log_msg ":: Number of lines: $num_lines";

	my $num_left = 0;
	my $line = 0;
	my $acm = 0;

	my $getter;

	if ($type eq 'fastq') {
		log_msg ":: Setting fastq validation and getter";
		$num_left = int($num_lines / 4);

		$getter = sub {
			my @stack;

			for (1..4) {
				$line++;
				defined(my $entry = <$fh>)
					or die "Truncated fastq entry in '$file' at line $line\n";
				push @stack => $entry;
			}

			chomp @stack;

			if ($stack[0] !~ /^\@/ || $stack[2] !~ /^\+/) {
				die "Fastq entry at '$file' line '", $line - 3, "' not seems to be a valid read\n";
			}

			if (length $stack[3] != $size) {
				die "Fastq entry in '$file' at line '$line' do not have length $size\n";
			}

			return $stack[3];
		};
	} else {
		log_msg ":: Setting raw validation and getter";
		$num_left = $num_lines;

		$getter = sub {
			$line++;
			chomp(my $entry = <$fh>);

			if (length $entry != $size) {
				die "Error parsing '$file': Line $line do not have length $size\n";
			}

			return $entry;
		};
	}

	log_msg ":: Calculating the  number of entries to pick ...";
	my $picks = $num_left < 1000 ? $num_left : 1000;
	my $picks_left = $picks;

	my @quality;

	log_msg ":: Picking $picks entries in '$file' ...";
	while ($picks_left > 0) {
		my $entry = $getter->();

		my $rand = int(rand($num_left));
		if ($rand < $picks_left) {
			push @quality => $entry;
			$picks_left--;
			if ($picks >= 10 && (++$acm % int($picks/10) == 0)) {
				log_msg sprintf "   ==> %d%% processed\n", ($acm / $picks) * 100;
			}
		}

		$num_left--;
	}

	$fh->close
		or die "Cannot close file '$file'\n";

	return $self->_index_quality(\@quality, $size);
}

sub _wcl {
	my ($self, $file) = @_;
	my $fh = $self->with_open_r($file);
	my $num_lines = 0;
	$num_lines++ while <$fh>;
	$fh->close;
	return $num_lines;
}

sub retrievedb {
	my ($self, $quality_profile) = @_;
	my $schema = App::Sandy::DB->schema;

	my $rs = $schema->resultset('QualityProfile')->find({ name => $quality_profile });
	die "'$quality_profile' not found into database\n" unless defined $rs;

	my $compressed = $rs->matrix;
	die "quality-profile entry '$quality_profile' exists, but the related data is missing\n"
		unless defined $compressed;

	my $deepth = $rs->deepth;
	my $size = $rs->size;

	gunzip \$compressed => \my $bytes;
	my $matrix = thaw $bytes;
	return ($matrix, $deepth, $size);
}

sub deletedb {
	my ($self, $quality_profile) = @_;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Checking if there is a quality-profile '$quality_profile' ...";
	my $rs = $schema->resultset('QualityProfile')->find({ name => $quality_profile });
	die "'$quality_profile' not found into database\n" unless defined $rs;

	log_msg ":: Found '$quality_profile'";
	die "'$quality_profile' is not a user provided entry. Cannot be deleted\n"
		unless $rs->is_user_provided;

	log_msg ":: Removing '$quality_profile' entry ...";

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
	my $user_provided = $schema->resultset('QualityProfile')->search(
		{ is_user_provided => 1 },
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

	my $rs = $schema->resultset('QualityProfile')->search(undef);

	while (my $quality = $rs->next) {
		my %hash = (
			size     => $quality->size,
			source   => $quality->source,
			provider => $quality->is_user_provided ? "user" : "vendor",
			date     => $quality->date
		);
		$report{$quality->name} = \%hash;
	}

	return \%report;
}
