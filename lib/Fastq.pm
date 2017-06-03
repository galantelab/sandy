#
#===============================================================================
#
#         FILE: Fastq.pm
#
#  DESCRIPTION: 'Fastq' base class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 05/12/2017 04:03:56 PM
#     REVISION: ---
#===============================================================================

package Fastq;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Params::Validate;
use My::Types;
use Carp 'croak';
use Quality;

use namespace::autoclean;

has 'sequencing_system' => (is => 'ro', isa => 'My:SeqSys', required => 1, coerce => 1);
has 'read_size'         => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_quality'          => (
	is         => 'ro',
	isa        => 'Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

sub _build_quality {
	my $self = shift;
	Quality->new(
		sequencing_system => $self->sequencing_system,
		read_size         => $self->read_size
	);
}

before 'sprint_fastq' => sub {
	my $self = shift;
	my ($header, $seq) = pos_validated_list(
		\@_,
		{ isa => 'Str'            },
		{ isa => 'ScalarRef[Str]' }
	);

	my $len = length $$seq;
	croak "seq length ($len) different of the read_size (" . $self->read_size . ")"
		if $len != $self->read_size;
};

sub sprint_fastq {
	my ($self, $header, $seq) = @_;
	
	my $quality = $self->gen_quality;

	my $fastq = "\@$header\n";
	$fastq .= "$$seq\n";
	$fastq .= "+$header\n";
	$fastq .= "$$quality";

	return $fastq;
}

__PACKAGE__->meta->make_immutable;

1;
