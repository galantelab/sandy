package App::Sandy::DB::Handle::Variation;
# ABSTRACT: Class to handle structural variation database schemas.

use App::Sandy::Base 'class';
use App::Sandy::DB;
use IO::Compress::Gzip 'gzip';
use IO::Uncompress::Gunzip 'gunzip';
use Storable qw/nfreeze thaw/;
use Scalar::Util qw/looks_like_number refaddr/;
use List::Util 'max';

with qw/App::Sandy::Role::IO App::Sandy::Role::SeqID/;

our $VERSION = '0.23'; # VERSION

sub insertdb {
	my ($self, $file, $name, $source, $is_user_provided, $type, @args) = @_;
	my $schema = App::Sandy::DB->schema;

	log_msg ":: Checking if there is already a structural variation '$name' ...";
	my $rs = $schema->resultset('StructuralVariation')->find({ name => $name });
	if ($rs) {
		die "There is already a structural variation '$name'\n";
	} else {
		log_msg ":: structural variation '$name' not found";
	}

	log_msg ":: Indexing '$file'";
	log_msg ":: It may take a while ...";
	my $indexed_file;

	if ($type eq 'raw') {
		$indexed_file = $self->_index_snv($file);
	} elsif ($type eq 'vcf') {
		$indexed_file = $self->_index_vcf($file, @args);
	} else {
		croak "No type '$type'";
	}

	log_msg ":: Removing overlapping entries in structural variation file '$file', if any ...";
	$self->_validate_indexed_snv($indexed_file, $file);

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
	my ($self, $variation_file) = @_;

	my $fh = $self->with_open_r($variation_file);

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

		die "Not found all fields (SEQID, POSITION, ID, REFERENCE, OBSERVED, GENOTYPE) into file '$variation_file' at line $line\n"
			unless scalar @fields >= 6;

		die "Second column, position, does not seem to be a number into file '$variation_file' at line $line\n"
			unless looks_like_number($fields[1]);

		die "Second column, position, has a value lesser or equal to zero into file '$variation_file' at line $line\n"
			if $fields[1] <= 0;

		die "Fourth column, reference, does not seem to be a valid entry: '$fields[3]' into file '$variation_file' at line $line\n"
			unless $fields[3] =~ /^(\w+|-)$/;

		die "Fifth column, alteration, does not seem to be a valid entry: '$fields[4]' into file '$variation_file' at line $line\n"
			unless $fields[4] =~ /^(\w+|-)$/;

		die "Sixth column, genotype, has an invalid entry: '$fields[5]' into file '$variation_file' at line $line. Valid ones are 'HE' or 'HO'\n"
			unless $fields[5] =~ /^(HE|HO)$/;

		if ($fields[3] eq $fields[4]) {
			warn "There is an alteration equal to the reference at '$variation_file' line $line. I will ignore it\n";
			next;
		}

		# Sequence inside perl begins at 0
		my $position = int($fields[1] - 1);

		# Compare the alterations and reference to guess the max variation on sequence
		my $size_of_variation = max map { length } $fields[3], $fields[4];
		my $high = $position + $size_of_variation - 1;

		my %variation = (
			seq_id => $fields[0],
			id     => $fields[2],
			ref    => $fields[3],
			alt    => $fields[4],
			plo    => $fields[5],
			pos    => $position,
			low    => $position,
			high   => $high,
			line   => $line
		);

		push @{ $indexed_snv{$self->with_std_seqid($fields[0])} } => \%variation;
	}

	close $fh
		or die "Cannot close structural variation file '$variation_file': $!\n";

	return \%indexed_snv;
}

sub _index_vcf {
	my ($self, $vcf_file, $sample_name) = @_;

	my $fh = $self->with_open_r($vcf_file);

	my $magic = <$fh>;
	chomp $magic;

	if ($magic !~ /^##fileformat=VCFv\d+(\.\d+)?$/) {
		log_msg ":: Putative VCF file '$vcf_file' does not have the required 'fileformat=VCFv{VERSION}' field\n";
		log_msg ":: Continue anyway ...\n";
	}

	my $sample_i = 9;
	my $has_header = 0;
	my $line = 1;
	my %indexed_snv;

	while (<$fh>) {
		$line ++;

		next if /^##/;
		next if /^\s*$/;

		chomp;
		my @fields = split /\t/;

		if (/^#/) {
			my $number_of_fields = scalar @fields;

			if ($number_of_fields < 8) {
				die "Invalid header: Less than 8 columns at line $line\n";
			} elsif ($number_of_fields == 8) {
				die "No genotype data found in the header at line $line\n";
			} elsif ($number_of_fields == 9) {
				die "Invalid header: Missing sample data at line $line\n";
			}

			my @samples = splice @fields, 9;

			if (defined $sample_name) {
				my %columns;

				for my $i (0..$#samples) {
					$columns{$samples[$i]} = $i;
				}

				if (not exists $columns{$sample_name}) {
					die "Not found sample named '$sample_name' at file '$vcf_file'\n";
				}

				$sample_i += $columns{$sample_name};
			} else {
				$sample_name = $samples[$sample_i];
			}

			$has_header = 1;
			next;
		}

		unless ($has_header) {
			die "No header found in file '$vcf_file'\n";
		}

		die "Not found all columns into file '$vcf_file' at line $line\n"
			unless scalar @fields > 9;

		die "Second column, position, does not seem to be a number into file '$vcf_file' at line $line\n"
			unless looks_like_number($fields[1]);

		die "Second column, position, has a value lesser or equal to zero into file '$vcf_file' at line $line\n"
			if $fields[1] <= 0;

		die "Fourth column, reference, does not seem to be a valid entry: '$fields[3]' into file '$vcf_file' at line $line\n"
			unless $fields[3] =~ /^(<\w+(:\w+)*>|\w+|-)$/;

		die "Fifth column, alternate, does not seem to be a valid entry: '$fields[4]' into file '$vcf_file' at line $line\n"
			unless $fields[4] =~ /^(\w+|<\w+(:\w+)*>|-|\*)(,(\w+|<\w+(:\w+)*>|-|\*))*$/;

		die "No genotype field found in format column at line $line\n"
			unless $fields[8] =~ /^GT:?/;

		die "Sample '$sample_name', column '$sample_i', does not seem to be a valid entry: '$fields[$sample_i]' into file '$vcf_file' at line $line\n"
			unless $fields[$sample_i] =~ /^[0-9.]+([\/\|][0-9.])?:*/;

		if ($fields[3] eq $fields[4]) {
			log_msg ":: There is an alternate equal to the reference at '$vcf_file' line $line. I will ignore it\n";
			next;
		}

		# No support for structural variation <VAR>
		# So ignore it
		if ($fields[3] =~ /<\w+>/ || $fields[4] =~ /<\w+>/) {
			next;
		}

		# Ignore missing alleles
		if ($fields[4] =~ /\*/) {
			next;
		}

		my @alternates = split /,/ => $fields[4];
		my $genotype = (split /:/ => $fields[$sample_i])[0];

		my ($plo, $alternate);
		my ($g1, $g2) = split /\|/ => $genotype;


		if ($g1 eq '.' || (defined $g2 && $g2 eq '.')) {
			next;
		}

		# Homozygosity or haploid chromossome
		if (! defined($g2) || ($g1 == $g2)) {
			# No variation
			next if $g1 == 0;
			$alternate = $alternates[$g1 - 1];
			$plo = 'HO';
		} else {
			# The alternate is the one with the max index, in the case
			# of a variation with the two alleles been alterations
			my $i = $g1 > $g2
				? $g1 - 1
				: $g2 - 1;
			$alternate = $alternates[$i];
			$plo = 'HE';
		}

		# Sequence inside perl begins at 0
		my $position = int($fields[1] - 1);

		# Compare the alterations and reference to guess the max variation on sequence
		my $size_of_variation = max map { length } $fields[3], $alternate;
		my $high = $position + $size_of_variation - 1;

		my %variation = (
			seq_id => $fields[0],
			id     => $fields[2],
			ref    => $fields[3],
			alt    => $alternate,
			plo    => $plo,
			pos    => $position,
			low    => $position,
			high   => $high,
			line   => $line
		);

		push @{ $indexed_snv{$self->with_std_seqid($fields[0])} } => \%variation;
	}

	close $fh
		or die "Cannot close vcf file '$vcf_file': $!\n";

	return \%indexed_snv;
}

sub _validate_indexed_snv {
	my ($self, $indexed_snv, $variation_file) = @_;

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
				my $valid_snvs = $self->_validate_indexed_snv_cluster(\@snv_cluster, $variation_file);
				push @{ $indexed_snv->{$seq_id} } => @$valid_snvs;
				@snv_cluster = ();
			}

			push @snv_cluster => $next_snv;
			$high = max $high, $next_snv->{high};
			$prev_snv = $next_snv;
		}

		my $valid_snvs = $self->_validate_indexed_snv_cluster(\@snv_cluster, $variation_file);
		push @{ $indexed_snv->{$seq_id} } => @$valid_snvs;
	}
}

sub _validate_indexed_snv_cluster {
	my ($self, $snvs, $variation_file) = @_;

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

				my ($prev_ref, $prev_alt, $next_ref, $next_alt) =
					map {
						length($_) > 25
							? substr($_, 0, 25) . "..."
							: $_
					} ($prev_snv->{ref}, $prev_snv->{alt}, $next_snv->{ref}, $next_snv->{alt});

				if ($prev_size >= $next_size) {
					if ($variation_file) {
						log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s] at '%s' line %d"
							=> $prev_snv->{seq_id}, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_ref, $prev_alt, $prev_snv->{plo},
							$next_snv->{seq_id}, $next_snv->{pos}+1, $next_snv->{id}, $next_ref, $next_alt, $next_snv->{plo},
							$variation_file, $next_snv->{line};
					} else {
						log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s]"
							=> $prev_snv->{seq_id}, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_ref, $prev_alt, $prev_snv->{plo},
							$next_snv->{seq_id}, $next_snv->{pos}+1, $next_snv->{id}, $next_ref, $next_alt, $next_snv->{plo};
					}

					$blacklist{refaddr($next_snv)} = 1;
					next INNER;
				} else {
					if ($variation_file) {
						log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s] at '%s' line %d"
							=> $next_snv->{seq_id}, $next_snv->{pos}+1, $next_snv->{id}, $next_ref, $next_alt, $next_snv->{plo},
							$prev_snv->{seq_id}, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_ref, $prev_alt, $prev_snv->{plo},
							$variation_file, $prev_snv->{line};
					} else {
						log_msg sprintf ":: Alteration [%s %d %s %s %s %s] masks [%s %d %s %s %s %s]"
							=> $next_snv->{seq_id}, $next_snv->{pos}+1, $next_snv->{id}, $next_ref, $next_alt, $next_snv->{plo},
							$prev_snv->{seq_id}, $prev_snv->{pos}+1, $prev_snv->{id}, $prev_ref, $prev_alt, $prev_snv->{plo};
					}

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

	my %all_matrix;

	for my $sv (@$structural_variation) {
		my $rs = $schema->resultset('StructuralVariation')->find({ name => $sv });
		die "'$sv' not found into database\n" unless defined $rs;

		my $compressed = $rs->matrix;
		die "structural variation entry '$sv' exists, but the related data is missing\n"
			unless defined $compressed;

		gunzip \$compressed => \my $bytes;
		my $matrix = thaw $bytes;

		while (my ($seq_id, $data) = each %$matrix) {
			push @{ $all_matrix{$seq_id} } => @$data;
		}
	}

	if (scalar @$structural_variation > 1) {
		log_msg sprintf ":: Removing overlapping entries from '[%s]'. If any ..."
			=> join(', ', @$structural_variation);
		$self->_validate_indexed_snv(\%all_matrix);
	}

	return \%all_matrix;
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

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::DB::Handle::Variation - Class to handle structural variation database schemas.

=head1 VERSION

version 0.23

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
