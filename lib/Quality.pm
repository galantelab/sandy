#
#===============================================================================
#
#         FILE: Quality.pm
#
#  DESCRIPTION: Analyses a fastq set and generate a weight matrix based on the quality
#               frequence for each position
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 17-02-2017 18:50:19
#     REVISION: ---
#===============================================================================

package Quality;

use Moose;
use MooseX::StrictConstructor;
use My::Types;
use Storable qw/file_magic retrieve/;
use Carp 'croak';
use File::Basename;
use File::Spec;

use namespace::autoclean;

has 'sequencing_system' => (is => 'ro', isa => 'My:SeqSys', required => 1, coerce => 1);
#TODO verify if read_size is not bigger than chosen sequencing_system length
has 'read_size'         => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_quality'          => (
	is         => 'ro',
	isa        => 'My:QualityH',
	builder    => '_build_quality',
	lazy_build => 1
);

my $LIB_PATH            = dirname(__FILE__);
my $QUALITY_MATRIX      = "sequencing_system.perldata";
my @QUALITY_MATRIX_PATH = (
	File::Spec->catdir($LIB_PATH, "..", "share"),
	File::Spec->catdir($LIB_PATH, "auto", "share", "dist", "Simulate-Reads")
);

#TODO %quality { sequencing_system } { size }
#                     -> { mtx } { len }
sub _build_quality {
	my $self = shift;

	my $quality_matrix;

	for my $path (@QUALITY_MATRIX_PATH) {
		my $file = File::Spec->catfile($path, $QUALITY_MATRIX);
		if (-f $file) {
			$quality_matrix = $file;
			last;
		}
	}
	
	croak "$QUALITY_MATRIX not found in @QUALITY_MATRIX_PATH" unless defined $quality_matrix;

	my $info = file_magic $quality_matrix;
	croak "$quality_matrix is not a perldata file" unless defined $info;

	my $quality = retrieve $quality_matrix;
	croak "Unable to retrieve from $quality_matrix!" unless defined $quality;

	croak "Unable to retrieve " . $self->sequencing_system . " from $quality_matrix"
		unless exists $quality->{$self->sequencing_system};
	
	my $quality_by_system = $quality->{$self->sequencing_system};
	return $quality_by_system;
}

sub gen_quality {
	my $self = shift;

	my $quality_mtx = $self->_quality->{mtx};
	my $quality_len = $self->_quality->{len};

	my $quality;
	
	for (my $i = 0; $i < $self->read_size; $i++) {
		$quality .= $quality_mtx->[$i][int(rand($quality_len))];
	}

	return \$quality;
}

__PACKAGE__->meta->make_immutable;

1;
