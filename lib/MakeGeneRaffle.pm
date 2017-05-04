#
#===============================================================================
#
#         FILE: MakeGeneRaffle.pm
#
#  DESCRIPTION: Based in a expression matrix, it raffles a gene.
#               
#               use MakeGeneRaffle;
#
#               my $gr = MakeGeneRaffle->new(
#               	expression_matrix => <FILE>,
#               	list_of_genes     => <FILE>
#               );
#
#               for (1..N) {
#               	my $gene = $gr->gene_raffle;
#               	...
#               }
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 09-03-2017 20:37:45
#     REVISION: ---
#===============================================================================

package MakeGeneRaffle;

use Moose;
use Carp 'croak';
use namespace::autoclean;

with 'Role::WeightedRaffle';

has 'list_of_genes'     => (is => 'ro', isa => 'Str', required => 1);
has 'expression_matrix' => (is => 'ro', isa => 'Str', required => 1);
has '_expression_table' => (is => 'rw', isa => 'HashRef');

sub BUILD {
	my $self = shift;
	my $freq = $self->_get_freq;
	my $expression_table = $self->_calculate_weight($freq);
	$self->_expression_table($expression_table);
}

sub _get_freq {
	my $self = shift;
	my $list = $self->_index_list_of_genes;

	my $fh;
	if ($self->expression_matrix =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->expression_matrix
			or croak "Not possible to open pipe to " . $self->expression_matrix . ": $!";
	} else {
		open $fh, "<" => $self->expression_matrix
			or croak "Not possible to read " . $self->expression_matrix . ": $!";
	}

	my %freq;
	while (<$fh>) {
		chomp;
		my @t = split /\t/;
		next unless $list->{$t[0]};
		$freq{$t[0]} = $t[1];
	}
	
	close $fh;
	return \%freq;
}

sub _index_list_of_genes {
	my $self = shift;

	my $fh;
	if ($self->list_of_genes =~ /\.gz$/) {
		open $fh, "-|" => "gunzip -c " . $self->list_of_genes
			or croak "Not possible to open pipe to " . $self->list_of_genes . ": $!";
	} else {
		open $fh, "<" => $self->list_of_genes
			or croak "Not possible to read " . $self->list_of_genes . ": $!";
	}

	my %list = map {chomp; $_ => 1} <$fh>;
	close $fh;
	return \%list;
}

sub gene_raffle {
	my $self = shift;
	my $expression_table = $self->_expression_table;

	my $range = int(rand($expression_table->{acm} + 1));
	my $weights = $expression_table->{weight};

	return $self->_search($weights, 0, $#{$weights}, $range);
}

__PACKAGE__->meta->make_immutable;

1;
