package App::SimulateReads::DB::Handle::Quality;
# ABSTRACT: Class to handle quality database schemas.

use App::SimulateReads::Base 'class';
use App::SimulateReads::DB;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;

with 'App::SimulateReads::Role::IO';

# VERSION
 
sub insertdb {
	my ($self, $file, $sequencing_system, $size, $source, $is_user_provided, $type) = @_;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Checking if there is already a sequencing-system '$sequencing_system' ...";
	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	if ($seq_sys_rs) {
		log_msg ":: Found '$sequencing_system'";
		log_msg ":: Searching for a quality entry '$sequencing_system:$size' ...";
		my $quality_rs = $seq_sys_rs->search_related('qualities' => { size => $size })->single;
		if ($quality_rs) {
			croak "There is already a quality entry for $sequencing_system:$size";
		}
		log_msg ":: Not found '$sequencing_system:$size'";
	} else {
		log_msg ":: sequencing-system '$sequencing_system' not found";
	}

	my ($arr, $deepth);

	if ($type !~ /^(fastq|raw)$/) {
		croak "Unknown indexing type '$type': Valids are 'raw' and 'fastq'";
	}

	log_msg ":: Indexing '$file'. It may take several minutes ...";
	($arr, $deepth) = $self->_index_quality_type($file, $size, $type);

	log_msg ":: Converting array to bytes ...";
	my $bytes = nfreeze $arr;
	log_msg ":: Compressing bytes ...";
	gzip \$bytes => \my $compressed;

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	unless ($seq_sys_rs) {
		log_msg ":: Creating sequencing-system entry for '$sequencing_system' ...";
		$seq_sys_rs = $schema->resultset('SequencingSystem')->create({ name => $sequencing_system });
	}

	log_msg ":: Storing quality matrix entry at '$sequencing_system:$size'...";
	my $quality_rs = $seq_sys_rs->create_related( qualities => {
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
	my $fh = $self->my_open_r($file);

	log_msg ":: Counting number of lines in '$file' ...";
	my $num_lines = $self->_wcl($file);
	log_msg ":: Number of lines: $num_lines";

	my $num_left = 0;
	my $line = 0;
	my $acm = 0;

	my $getter;

	given ($type) {
		when ('fastq') {
			log_msg ":: Setting fastq validation and getter";
			$num_left = int($num_lines / 4);

			$getter = sub {
				my @stack;

				for (1..4) {
					$line++;
					defined(my $entry = <$fh>)
						or croak "Truncated fastq entry in '$file' at line $line";
					push @stack => $entry;
				}

				chomp @stack;

				if ($stack[0] !~ /^\@/ || $stack[2] !~ /^\+/) {
					croak "Fastq entry at '$file' line '", $line - 3, "' not seems to be a valid read";	
				}

				if (length $stack[3] != $size) {
					croak "Fastq entry in '$file' at line '$line' do not have length $size";
				}

				return $stack[3];
			}
		}
		default {
			log_msg ":: Setting raw validation and getter";
			$num_left = $num_lines;

			$getter = sub {
				$line++;
				chomp(my $entry = <$fh>);

				if (length $entry != $size) {
					croak "Error parsing '$file': Line $line do not have length $size";
				}

				return $entry;
			}
		}
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
			if (++$acm % int($picks/10) == 0) {
				log_msg sprintf "   ==> %d%% processed\n", ($acm / $picks) * 100;
			}
		}

		$num_left--;
	}

	$fh->close
		or croak "Cannot close file '$file'";

	return $self->_index_quality(\@quality, $size);
}

sub _wcl {
	my ($self, $file) = @_;
	my $fh = $self->my_open_r($file);
	my $num_lines = 0;
	$num_lines++ while <$fh>;
	$fh->close;
	return $num_lines;
}

sub retrievedb {
	my ($self, $sequencing_system, $size) = @_;
	my $schema = App::SimulateReads::DB->schema;

	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	croak "'$sequencing_system' not found into database" unless defined $seq_sys_rs;

	my $quality_rs = $seq_sys_rs->search_related('qualities' => { size => $size })->single;
	croak "Not found size '$size' for sequencing system '$sequencing_system'" unless defined $quality_rs;

	my $compressed = $quality_rs->matrix;
	my $deepth = $quality_rs->deepth;
	croak "Quality profile not found for '$sequencing_system:$size'" unless defined $compressed;

	gunzip \$compressed => \my $bytes;
	my $matrix = thaw $bytes;
	return ($matrix, $deepth);
}

sub deletedb {
	my ($self, $sequencing_system, $size) = @_;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Checking if there is a sequencing-system '$sequencing_system' ...";
	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	croak "'$sequencing_system' not found into database" unless defined $seq_sys_rs;
	log_msg ":: Found '$sequencing_system'";

	log_msg ":: Searching for a quality entry '$sequencing_system:$size' ...";
	my $quality_rs = $seq_sys_rs->search_related('qualities' => { size => $size })->single;
	croak "'$sequencing_system:$size' not found into database" unless defined $quality_rs;
	croak "'$sequencing_system:$size' is not a user provided entry. Cannot be deleted" unless $quality_rs->is_user_provided;

	log_msg ":: Found. Removing '$sequencing_system:$size' entry ...";

	# Begin transation
	my $guard = $schema->txn_scope_guard;
	
	$quality_rs->delete;
	$seq_sys_rs->search_related('qualities' => undef)->single
		or $seq_sys_rs->delete;

	# End transation
	$guard->commit;
}

sub restoredb {
	my $self = shift;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Searching for user-provided entries ...";
	my $user_provided = $schema->resultset('Quality')->search(
		{ is_user_provided => 1 },
		{ prefetch => ['sequencing_system'] }
	);

	my $entry = $user_provided->next;
	if ($entry) {
		log_msg ":: Found:";
		do {
			log_msg '   ==> ' . $entry->sequencing_system->name . ':' . $entry->size;
		} while ($entry = $user_provided->next);
	} else {
		croak "Not found user-provided entries. There is no need to restoring\n";
	}

	log_msg ":: Removing all user-provided entries ...";

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	# Select all vendor qualities
	my $inside_rs = $schema->resultset('Quality')->search(
		{ is_user_provided => 0 }
	);

	# Select all sequencing_system that is not vendor-provided
	my $seq_sys_rs = $schema->resultset('SequencingSystem')->search(
		{ 'me.id' => { -not_in => $inside_rs->get_column('sequencing_system_id')->as_query } }
	);

	# Remove all sequencing_system that is not vendor-provided
	# It will trigger delete casacade
	$seq_sys_rs->delete_all;

	# Select all qualities that is user-provided
	my $quality_rs = $schema->resultset('Quality')->search(
		{ is_user_provided => 1 }
	);

	# Remove all user-provided qualities that is inside a vendor-provided
	# sequencing_system but with a custom user-provided size
	$quality_rs->delete;

	# End transation
	$guard->commit;
}

sub make_report {
	my $self = shift;
	my $schema = App::SimulateReads::DB->schema;
	my %report;

	my $quality_rs = $schema->resultset('Quality')->search(
		undef,
		{ prefetch => ['sequencing_system'] }
	);

	while (my $quality = $quality_rs->next) {
		my %hash = (
			size     => $quality->size,
			source   => $quality->source,
			provider => $quality->is_user_provided ? "user" : "vendor"
		);
		push @{ $report{$quality->sequencing_system->name} } => \%hash;
	}

	return \%report;
}
