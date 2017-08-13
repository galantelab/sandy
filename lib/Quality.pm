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

use My::Base 'class';
use My::Types;
use Storable qw/file_magic retrieve/;
use File::Basename 'dirname';
use File::Spec;
use Math::CDF 'ppois';

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'sequencing_system'  => (is => 'ro', isa => 'My:SeqSys', required => 1, coerce => 1);
#TODO read_size will be limited according to the sequencing_system chosen
has 'read_size'          => (is => 'ro', isa => 'My:IntGt0', required => 1);
has '_quality_by_system' => (
	is         => 'ro',
	isa        => 'My:QualityH',
	builder    => '_build_quality_by_system',
	lazy_build => 1
);
has '_gen_quality'      => (
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_gen_quality',
	lazy_build => 1
);

#-------------------------------------------------------------------------------
#  Hardcoded paths for sequencing_system
#-------------------------------------------------------------------------------
my $LIB_PATH            = dirname(__FILE__);
my $QUALITY_MATRIX      = "sequencing_system.perldata";
my @QUALITY_MATRIX_PATH = (
	File::Spec->catdir($LIB_PATH, "..", "share"),
	File::Spec->catdir($LIB_PATH, "auto", "share", "dist", "Simulate-Reads")
);

#TODO %quality { sequencing_system } { size }
#                     -> { mtx } { len }
#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _build_quality_by_system (BUILDER)
#   PARAMETERS: Void
#      RETURNS: $quality_by_system My:QualityH
#  DESCRIPTION: Searches into the paths for sequencing_system.perldata where is
#               found the quality distribution for a given system
#       THROWS: If sequencing_system not found, or a given system is not stored
#               in the database, throws an exception
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_quality_by_system {
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
} ## --- end sub _build_quality_by_system

#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: gen_quality
#   PARAMETERS: Void
#      RETURNS: \$quality Ref Str
#  DESCRIPTION: Calcultes a quality string by raffle inside a quality matrix -
#               where each position is a vector encoding a distribution. So
#               if the string length is 100 bases, it needs to raffle 100 times.
#               The more present is a given quality, the more chance to be raffled
#               it will be
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub gen_quality {
	my $self = shift;
	my $gen_quality = $self->_gen_quality;
	my $quality;
	for (my $i = 0; $i < $self->read_size; $i++) {
		$quality .= $gen_quality->($i);
	}
	return \$quality;
} ## --- end sub gen_quality

sub _build_gen_quality {
	my $self = shift;
	my $fun;
	given ($self->sequencing_system) {
		when ('poisson') {
			$fun = sub { $self->_map_quality_by_poisson_dist };
		}
		default {
			$fun = sub { $self->_map_quality_by_system };
		}
	}
	return $fun;
}

sub _map_quality_by_system {
	my ($self, $pos) = @_;
	return $self->_quality_by_system->{mtx}[$pos][int(rand($self->_quality_by_system->{len}))];
}

sub _map_quality_by_poisson_dist {
	my ($self, $pos) = @_;
	my $prob = 0.00000001 + ppois($pos, $self->read_size);
	my $score = (log($prob)/log(10)) * (-10);
	my $rand_factor = rand($prob * 0.1);
	my $ind = int(rand(2)) ? $score + $rand_factor : $score - $rand_factor;
	return chr int($ind + 33);
}

## --- end class Quality
