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
 
my $DB = 'quality_profile.db';
my @DB_PATH = (
	file(__FILE__)->dir->parent->parent->file('share'),
	file(__FILE__)->dir->file('auto', 'share', 'dist', 'Simulate-Reads')
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
	return Quality::Schema->connect("dbi:SQLite:$db", "", "", { RaiseError => 1, PrintError => 0 });
}

sub insertdb {
	my ($self, $file, $sequencing_system, $size, $source, $type) = @_;
	my $schema = $self->schema;

	log_msg ":: Checking if there is already a sequencing-system '$sequencing_system' ...";
	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	if ($seq_sys_rs) {
		log_msg ":: Found '$sequencing_system'";
		log_msg ":: Searching for a quality entry '$sequencing_system:$size' ...";
		my $quality_rs = $schema->resultset('Quality')->find(
			{
				'sequencing_system.name' => $sequencing_system,
				'me.size'                => $size 
			},
			{  prefetch => ['sequencing_system'] }
		);
		if ($quality_rs) {
			croak "There is already a quality entry for $sequencing_system:$size";
		}
		log_msg ":: Not found '$sequencing_system:$size'";
	} else {
		log_msg ":: sequencing-system '$sequencing_system' not found";
	}

	log_msg ":: Indexing '$file' ...";
	my $arr;
	given ($type) {
		when ('raw') {
			$arr = $self->_index_quality_raw($file, $size);
		}
		when ('fastq') {
			$arr = $self->_index_quality_fastq($file, $size);
		}
		default {
			croak "Unknown indexing type '$type': Valids are 'raw' and 'fastq'";
		}
	}

	log_msg ":: Converting array to bytes ...";
	my $bytes = nfreeze $arr;
	log_msg ":: Compressing bytes ...";
	gzip \$bytes => \my $compressed;

	unless ($seq_sys_rs) {
		log_msg ":: Creating sequencing-system entry for '$sequencing_system' ...";
		$seq_sys_rs = $schema->resultset('SequencingSystem')->create({ name => $sequencing_system });
	}

	log_msg ":: Storing quality matrix entry ...";
	my $quality_rs = $seq_sys_rs->create_related( qualities => {
		source => $source,
		size   => $size,
		matrix => $compressed
	});
}

sub _index_quality {
	my ($self, $quality_ref, $size) = @_;
	my $number_of_quality_entries = 1000;

	my $number_of_entries = scalar @$quality_ref;
	log_msg "entry: $number_of_entries";
	my $slice = $number_of_entries < $number_of_quality_entries ? $number_of_entries : $number_of_quality_entries;
	log_msg "slice: $slice";
	my @quality_shuffled = shuffle @$quality_ref;
	my @quality_slice = splice(@quality_shuffled, 0, $slice);

	my @arr;
	for (@quality_slice) {
		my @tmp = split //;
		for (my $i = 0; $i < $size; $i++) {
			push @{ $arr[$i] } => $tmp[$i];
		}
	}

	return \@arr;
}

sub _index_quality_raw {
	my ($self, $file, $size) = @_;
	my $fh = $self->my_open_r($file);
	my $number_of_quality_entries = 1000;
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
	my $number_of_quality_entries = 1000;
	my $line = 0;
	my @quality;

	while (1) {
		my @stack;
		for (1..4) {
			$line++;
			defined(my $entry = <$fh>)
				or croak "Truncated fastq entry at '$file' line $line";
			push @stack => $entry;
		}

		chomp @stack;
		if ($stack[0] !~ /^\@/ || $stack[2] !~ /^\+/) {
			croak "Fastq entry at '$file' line '", $line - 3, "' not seems to be a valid read";	
		}

		if (length $stack[3] != $size) {
			croak "Fastq entry at '$file' line '", $line - 3, "' do not have length $size";
		}
		
		push @quality => $stack[3];
		last if eof;
	}

	close $fh
		or croak "Cannot close file '$file'";

	return $self->_index_quality(\@quality, $size);
}

sub retrievedb {
	my ($self, $sequencing_system, $size) = @_;
	my $schema = $self->schema;

	my $seq_sys_rs = $schema->resultset('SequencingSystem')->find({ name => $sequencing_system });
	croak "'$sequencing_system' not found into database" unless defined $seq_sys_rs;

	my $quality_rs = $schema->resultset('Quality')->find(
		{
			'sequencing_system.name' => $sequencing_system,
			'size'                   => $size
		},
		{ prefetch => ['sequencing_system'] }
	); 
	croak "Not found size '$size' for sequencing system '$sequencing_system'" unless defined $quality_rs;

	my $compressed = $quality_rs->matrix;
	croak "Quality profile not found for '$sequencing_system:$size'" unless defined $compressed;
	gunzip \$compressed => \my $bytes;
	return thaw $bytes;
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
			size   => $quality->size,
			source => $quality->source
		);
		push @{ $report{$quality->sequencing_system->name} } => \%hash;
	}

	return \%report;
}
