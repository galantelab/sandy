package App::SimulateReads::DB::Handle::Expression;
# ABSTRACT: Class to handle expression-matrix database schemas.

use App::SimulateReads::Base 'class';
use App::SimulateReads::DB;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;
use Scalar::Util 'looks_like_number';

with 'App::SimulateReads::Role::IO';

# VERSION

sub insertdb {
	my ($self, $file, $name, $source, $is_user_provided) = @_;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Checking if there is already an expression-matrix '$name' ...";
	my $rs = $schema->resultset('ExpressionMatrix')->find({ name => $name });
	if ($rs) {
		die "There is already an expression-matrix '$name'\n";
	} else {
		log_msg ":: expression-matrix '$name' not found";
	}

	log_msg ":: Indexing '$file' ...";
	my $indexed_file = $self->_index_expression_matrix($file);

	log_msg ":: Converting data to bytes ...";
	my $bytes = nfreeze $indexed_file;
	log_msg ":: Compressing bytes ...";
	gzip \$bytes => \my $compressed;

	# Begin transation
	my $guard = $schema->txn_scope_guard;

	log_msg ":: Storing expression-matrix '$name'...";
	$rs = $schema->resultset('ExpressionMatrix')->create({
		name             => $name,
		source           => $source,
		is_user_provided => $is_user_provided,
		matrix           => $compressed
	});

	# End transation
	$guard->commit;
}

sub _index_expression_matrix {
	my ($self, $file) = @_;

	my $fh = $self->my_open_r($file);
	my %indexed_file;

	my $line = 0;
	while (<$fh>) {
		$line++;
		chomp;
		next if /^\s*$/;

		my @fields = split;

		die "Error parsing expression-matrix '$file': Seqid (first column) not found at line $line\n"
			unless defined $fields[0];
		die "Error parsing expression-matrix '$file': Count (second column) not found at line $line\n"
			unless defined $fields[1];
		die "Error parsing expression-matrix '$file': Count (second column) does not look like a number at line $line\n"
			if not looks_like_number($fields[1]);

		# Only throws a warning, because it is common zero values in expression matrix
		if ($fields[1] <= 0) {
			log_msg ":: Parsing expression-matrix '$file': Ignoring seqid '$fields[0]': Count (second column) lesser or equal to zero at line $line\n";
			next;
		}

		$indexed_file{$fields[0]} = $fields[1];
	}

	unless (%indexed_file) {
		die "Error parsing expression-matrix '$file': Maybe the file is empty\n"
	}

	$fh->close
		or die "Cannot close expression-matrix $file: $!\n";

	return \%indexed_file;
}

sub retrievedb {
	my ($self, $expression_matrix) = @_;
	my $schema = App::SimulateReads::DB->schema;

	my $rs = $schema->resultset('ExpressionMatrix')->find({ name => $expression_matrix });
	die "'$expression_matrix' not found into database\n" unless defined $rs;

	my $compressed = $rs->matrix;
	die "expression-matrix entry '$expression_matrix' exists, but the related data is missing\n"
		unless defined $compressed;

	gunzip \$compressed => \my $bytes;
	my $matrix = thaw $bytes;
	return $matrix;
}

sub deletedb {
	my ($self, $expression_matrix) = @_;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Checking if there is an expression-matrix '$expression_matrix' ...";
	my $rs = $schema->resultset('ExpressionMatrix')->find({ name => $expression_matrix });
	die "'$expression_matrix' not found into database\n" unless defined $rs;

	log_msg ":: Found '$expression_matrix'";
	die "'$expression_matrix' is not a user provided entry. Cannot be deleted\n"
		unless $rs->is_user_provided;

	log_msg ":: Removing '$expression_matrix' entry ...";

	# Begin transation
	my $guard = $schema->txn_scope_guard;
	
	$rs->delete;

	# End transation
	$guard->commit;
}

sub restoredb {
	my $self = shift;
	my $schema = App::SimulateReads::DB->schema;

	log_msg ":: Searching for user-provided entries ...";
	my $user_provided = $schema->resultset('ExpressionMatrix')->search(
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
	my $schema = App::SimulateReads::DB->schema;
	my %report;

	my $rs = $schema->resultset('ExpressionMatrix')->search(undef);

	while (my $expression_matrix = $rs->next) {
		my %hash = (
			source   => $expression_matrix->source,
			provider => $expression_matrix->is_user_provided ? "user" : "vendor",
			date     => $expression_matrix->date
		);
		push @{ $report{$expression_matrix->name} } => \%hash;
	}

	return \%report;
}
