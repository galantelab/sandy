#
#===============================================================================
#
#         FILE: SimulateTranscriptome.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 04/30/2017 02:39:26 AM
#     REVISION: ---
#===============================================================================

package SimulateTranscriptome; #Juntar MakeGeneRaffle e MakeFastqGff
 
use Moose;
use MakeQuality;
use Carp;
use namespace::autoclean;

use constant {
	CHR        => 0,
	STRAND     => 1,
	START_GENE => 2,
	END_GENE   => 3,
	NUM_EXON   => 4,
	START_EXON => 5,
	END_EXON   => 6,
	ID         => 7,
	NAME       => 8,
	TYPE       => 9
};

has 'geneseq_file'    => (is => 'ro', isa => 'Str', required => 1);
has 'geneinfo_file'   => (is => 'ro', isa => 'Str', required => 1);
has 'quality_file'    => (is => 'ro', isa => 'Str', required => 1);
has 'geneseq'         => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_geneseq',
	lazy_build => 1
);
has 'geneinfo'        => (
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_geneinfo',
	lazy_build => 1
);
has 'read_count'      => (
	is         => 'rw',
	isa        => 'HashRef',
	default    => sub { { } }
);
has 'quality'         => (
	is         => 'ro',
	isa        => 'MakeQuality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

sub _build_quality {
	my $self = shift;
	MakeQuality->new(
		quality_matrix => $self->quality_file,
		quality_size   => $self->read_size
	);
}

sub _build_geneseq {
	my $self = shift;

	my $fh;
	if ($self->geneseq_file =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->geneseq_file
			or croak "Not possible to open pipe to " . $self->geneseq_file . ": $!";
	} else {
		open $fh, "<" => $self->geneseq_file
			or croak "Not possible to read " . $self->geneseq_file . ": $!";
	}

	my %hash;
	while (<$fh>) {
		chomp;
		if (/^>/) {
			my $trancript_id = $_;
			$trancript_id =~ s/>//;
			chomp(my $seq = <$fh>);
			$hash{$trancript_id} = $seq;
		}
	}

	close $fh;
	return \%hash;
}

sub _build_geneinfo {
	my $self = shift;

	my $fh;
	if ($self->geneinfo_file =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->geneinfo_file
			or croak "Not possible to open pipe to " . $self->geneinfo_file . ": $!";
	} else {
		open $fh, "<" => $self->geneinfo_file
			or croak "Not possible to read " . $self->geneinfo_file . ": $!";
	}

	my %hash;
	while (<$fh>) {
		chomp;
		my @fields = split /\t/;

		my @start_exon = split /,/ => $fields[START_EXON];			
		my @end_exon = split /,/ => $fields[END_EXON];

		if (scalar @start_exon != scalar @end_exon) {
			croak "Different number of start and end exon positions at " . $self->geneinfo_file;
		}
		elsif (scalar @start_exon != $fields[NUM_EXON]) {
			croak "Different number of exons at " . $self->geneinfo_file;
		}

		my @exon;
		for (my $i = 0; $i < $fields[NUM_EXON]; $i++) {
			push @exon => {start => $start_exon[$i], end => $end_exon[$i]};
		}

		my %gene = (
			chr      => $fields[CHR],
			strand   => $fields[STRAND],
			start    => $fields[START_GENE],
			end      => $fields[END_GENE],
			num_exon => $fields[NUM_EXON],
			exon     => \@exon,
			id       => $fields[ID],
			type     => $fields[TYPE]
		);

		$hash{$fields[NAME]} = \%gene;
	}

	close $fh;
	return \%hash;
}

sub _debuggeneinfo {
	my $self = shift;
	require Data::Dumper;
	print Dumper($self->geneinfo);
}

sub _debuggeneseq {
	my $self = shift;
	require Data::Dumper;
	print Dumper($self->geneseq);
}

sub gff {
	my ($self, $gene) = @_;

	unless (defined $gene) {
		carp "Not defined gene";
		return;
	}

	my $geneinfo = $self->geneinfo;
	my $gene_h = $geneinfo->{$gene};

	unless (defined $gene_h) {
		carp "$gene not found inside " . $self->geneinfo_file;
		return;	
	}

	my $gff;
	if ($gene_h->{type} eq 'parental' or $gene_h->{type} eq 'non_parental') {
		$gff = $self->_gff_get_gene($gene);
	}
	elsif ($gene_h->{type} eq 'retrocopy') {
		$gff = $self->_gff_get_retrocopy($gene);
	}

	return $gff;
}

sub _gff_get_gene {
	my ($self, $gene) = @_;

	my $geneinfo = $self->geneinfo;
	my $gene_h = $geneinfo->{$gene};

	my $gff = "$gene_h->{chr}\tgencode_v19\ttranscript\t$gene_h->{start}\t$gene_h->{end}\t.\t$gene_h->{strand}\t.\tgene_name \"$gene\"; transcript_id \"$gene_h->{id}\"; gene_type \"$gene_h->{type}\";";

	my $exon = $gene_h->{exon};
	for (my $i = 0; $i < $gene_h->{num_exon}; $i++) {
		my $exon_number = $i + 1;
		$gff .= "\n$gene_h->{chr}\tgencode_v19\texon\t$exon->[$i]->{start}\t$exon->[$i]->{end}\t.\t$gene_h->{strand}\t.\tgene_name \"$gene\"; transcript_id \"$gene_h->{id}\"; gene_type \"$gene_h->{type}\"; exon_number $exon_number;";
	}

	return $gff;
}

sub _gff_get_retrocopy {
	my ($self, $gene) = @_;

	my $geneinfo = $self->geneinfo;
	my $gene_h = $geneinfo->{$gene};

	my $gff = "$gene_h->{chr}\trcpedia_data\tretrocopy\t$gene_h->{start}\t$gene_h->{end}\t.\t$gene_h->{strand}\t.\trcpedia_id \"$gene\";";

	return $gff;
}

sub get_read_count {
	my $self = shift;
	my $read_count = $self->read_count;
	my ($gene, $count) = each %$read_count;
	my $str = "$gene $count";
	$str .= "\n$gene $count" while ($gene, $count) = each %$read_count;
	return $str;
}

__PACKAGE__->meta->make_immutable;

1;
