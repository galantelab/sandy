#
#===============================================================================
#
#         FILE: Handle.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 20-08-2017 17:37:03
#     REVISION: ---
#===============================================================================

package Quality::Handle;

use My::Base 'class';
use Quality::Schema;
use Path::Class 'file';
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;
use List::Util 'shuffle';

with 'My::Role::IO';
 
#-------------------------------------------------------------------------------
#  Hardcoded paths for quality_profile
#-------------------------------------------------------------------------------
my $DB = 'quality_profile.db';
my @DB_PATH = (
	file(__FILE__)->dir->parent->parent->file('share'),
	file(__FILE__)->dir->parent->file('auto', 'share', 'dist', 'Simulate-Reads')
);

has 'schema' => (
	is         => 'ro',
	isa        => 'Quality::Schema',
	builder    => '_build_schema',
	lazy_build => 1,
);

sub _build_schema {
	my $self = shift;
	my $db;

	for my $path (@DB_PATH) {
		my $file = file($path, $DB);
		if (-f $file) {
			$db = $file;
			last;
		}
	}

	croak "$DB not found in @DB_PATH" unless defined $db;
	return Quality::Schema->connect(
		"dbi:SQLite:$db",
		"", 
		"", 
		{
			RaiseError    => 1,
			PrintError    => 0,
			on_connect_do => 'PRAGMA foreign_keys = ON'
		}
	);
}

sub insertdb {
	my ($self, $file, $sequencing_system, $size, $source, $is_user_provided, $type) = @_;
	my $schema = $self->schema;

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
	given ($type) {
		when ('raw') {
			log_msg ":: Indexing quality matrix '$file' ...";
			($arr, $deepth) = $self->_index_quality_raw($file, $size);
		}
		when ('fastq') {
			log_msg ":: Indexing fastq '$file'. It may take a while ...";
			($arr, $deepth) = $self->_index_quality_fastq($file, $size);
		}
		default {
			croak "Unknown indexing type '$type': Valids are 'raw' and 'fastq'";
		}
	}

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
#	my $deepth_default = 1000;

	my $deepth = scalar @$quality_ref;
#	my $slice = $deepth < $deepth_default ? $deepth : $deepth_default;

#	# Shuffled list of indexes into @$quality_ref
#	my @shuffled_indexes = shuffle 0 .. $#{ $quality_ref };
#	# Get just $slice of them.
#	my @pick_indexes = @shuffled_indexes[0 .. $slice - 1];
#	# Pick centries from @$quality_ref
#	my @quality_slice = @$quality_ref[@pick_indexes];

	my @arr;
	for (@$quality_ref) {
		my @tmp = split //;
		for (my $i = 0; $i < $size; $i++) {
			push @{ $arr[$i] } => $tmp[$i];
		}
	}

	return (\@arr, $deepth);
}

sub _index_quality_raw {
	my ($self, $file, $size) = @_;
	my $fh = $self->my_open_r($file);
	my @arr;
	my $line = 0;

	while (<$fh>) {
		$line++;
		chomp;
		if (length $_ != $size) {
			croak "Error parsing '$file': Line $line do not have length $size";
		}
		push @arr => $_;
	}

	close $fh
		or croak "Cannot close file '$file'";
	return $self->_index_quality(\@arr, $size);
}

sub _index_quality_fastq {
	my ($self, $file, $size) = @_;
	my $fh = $self->my_open_r($file);

	log_msg ":: Counting number of lines in '$file' ...";
	my $num_lines = $self->_wcl($file);
	log_msg ":: Number of lines: $num_lines";

	log_msg ":: Calculating the  number of entries to pick ...";
	my $num_left = int($num_lines / 4);
	my $picks = $num_left < 1000 ? $num_left : 1000;

	my $picks_left = $picks;
	my ($line, $entry) = (0, 0);
	my @quality;

	log_msg ":: Picking $picks random entries in '$file' ...";
	while ($picks_left > 0) {
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
		
		my $rand = int(rand($num_left));
		if ($rand < $picks_left) {
			push @quality => $stack[3];
			$picks_left--;
			if (++$entry % int($picks/10) == 0) {
				log_msg sprintf "   ==> %d%% processed\n", ($entry / $picks) * 100;
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
	my $schema = $self->schema;

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
	my $schema = $self->schema;

	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	croak "'$sequencing_system' not found into database" unless defined $seq_sys_rs;
	my $quality_rs = $seq_sys_rs->search_related('qualities' => { size => $size })->single;
	croak "'$sequencing_system:$size' not found into database" unless defined $quality_rs;
	croak "'$sequencing_system:$size' is not a user provided entry. Cannot be deleted" unless $quality_rs->is_user_provided;

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
	my $schema = $self->schema;

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	my $seq_sys_rs = $schema->resultset('SequencingSystem')->search(
		{ is_user_provided => 1  },
		{ prefetch => ['qualities'] }
	);

	$seq_sys_rs->delete_all;

	my $quality_rs = $schema->resultset('Quality')->search(
		{ is_user_provided => 1 }
	);

	$quality_rs->delete;

	# End transation
	$guard->commit;
}

sub make_report {
	my $self = shift;
	my $schema = $self->schema;
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
