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
use Storable qw/file_magic retrieve/;
use File::Basename 'dirname';
use File::Spec;

#-------------------------------------------------------------------------------
#  Moose attributes
#-------------------------------------------------------------------------------
has 'quality_profile'    => (is => 'ro', isa => 'My:QualityP', required => 1, coerce => 1);
#TODO read_size will be limited according to the quality_profile chosen
has 'read_size'          => (is => 'ro', isa => 'My:IntGt0',   required => 1);
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
#  Hardcoded paths for quality_profile
#-------------------------------------------------------------------------------
my $LIB_PATH            = dirname(__FILE__);
my $QUALITY_MATRIX      = "quality_profile.perldata";
my @QUALITY_MATRIX_PATH = (
	File::Spec->catdir($LIB_PATH, "..", "share"),
	File::Spec->catdir($LIB_PATH, "auto", "share", "dist", "Simulate-Reads")
);

#-------------------------------------------------------------------------------
#  Phred score table for poisson distribution simulation
#-------------------------------------------------------------------------------
my @PHRED_SCORE = (
	{
		score  => ['I', 'H', 'G', 'F', 'E', 'D', 'C', 'B', 'A', '@', '?'],
		size   => 11,
		ratio  => 1.5
	},
	{
		score  => ['>', '=', '<', ';', ':', '9', '8', '7', '6', '5'],
		size   => 10,
		ratio  => 2
	},
	{
		score  => ['4', '3', '2', '1', '0', '/', '.', '-', ',', '+'],
		size   => 10,
		ratio  => 2
	},
	{
		score  => ['*', ')', '(', '\'', '&', '%', '$', '#', '"', '!'],
		size   => 10,
		ratio  => 1
	}
);

#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _build_gen_quality (BUILDER)
#   PARAMETERS: Void
#      RETURNS: $fun CodeRef
#  DESCRIPTION: Dynamic linkage for quality profile generator 
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _build_gen_quality {
	my $self = shift;
	my $fun;

	given ($self->quality_profile) {
		when ('poisson') {
			$fun = sub { $self->_gen_quality_by_poisson_dist };
		}
		default {
			$fun = sub { $self->_gen_quality_by_system };
		}
	}

	return $fun;
} ## --- end sub _build_gen_quality

#TODO %quality { quality_profile } { size }
#                     -> { mtx } { len }
#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _build_quality_by_system (BUILDER)
#   PARAMETERS: Void
#      RETURNS: $quality_by_system My:QualityH
#  DESCRIPTION: Searches into the paths for quality_profile.perldata where is
#               found the quality distribution for a given system
#       THROWS: If quality_profile not found, or a given system is not stored
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

	croak "Unable to retrieve " . $self->quality_profile . " from $quality_matrix"
		unless exists $quality->{$self->quality_profile};
	
	my $quality_by_system = $quality->{$self->quality_profile};
	return $quality_by_system;
} ## --- end sub _build_quality_by_system

sub gen_quality {
	my $self = shift;
	my $gen_quality = $self->_gen_quality;
	return $gen_quality->();
} ## --- end sub gen_quality

#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _gen_quality_by_system (PRIVATE)
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
sub _gen_quality_by_system {
	my $self = shift;

	my $quality_mtx = $self->_quality_by_system->{mtx};
	my $quality_len = $self->_quality_by_system->{len};
	my $quality;

	for (my $i = 0; $i < $self->read_size; $i++) {
		$quality .= $quality_mtx->[$i][int(rand($quality_len))];
	}

	return \$quality;
} ## --- end sub _gen_quality_by_system

#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _gen_quality_by_poisson_dist
#   PARAMETERS: Void
#      RETURNS: \$quality Ref Str
#  DESCRIPTION: Calculates quality based in a cumulative poisson distribution
#       THROWS: no exceptions
#     COMMENTS: It uses the @PHRED_SCORE table to simulate a proportion score
#               similar to the poisson distribution
#     SEE ALSO: _poisson_dist
#===============================================================================
sub _gen_quality_by_poisson_dist {
	my $self = shift;
	my $quality;
	return $self->_poisson_dist(\$quality, $self->read_size, scalar @PHRED_SCORE);
} ## --- end sub _gen_quality_by_poisson_dist

#===  CLASS METHOD  ============================================================
#        CLASS: Quality
#       METHOD: _poisson_dist
#   PARAMETERS: $quality_ref Str Ref, $size Int > 0, $countdown Int >= 0
#      RETURNS: $quality_ref Str Ref
#  DESCRIPTION: Recursive routine that generates a quality string based in a
#               uniform random raffle into @PHRED_SCORE partitions. It works as
#               a poisson CDF
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: _gen_quality_by_poisson_dist
#===============================================================================
sub _poisson_dist {
	my ($self, $quality_ref, $size, $countdown) = @_;
	return $quality_ref if not $countdown;

	my $ratio = $PHRED_SCORE[4 - $countdown]{ratio};
	my $part = int($size / $ratio) + ($size % $ratio);
	my $score = $PHRED_SCORE[4 - $countdown]{score};
	my $score_size = $PHRED_SCORE[4 - $countdown]{size};

	for (my $i = 0; $i < $part; $i++) {
		$$quality_ref .= $score->[int(rand($score_size))];
	}

	return $self->_poisson_dist($quality_ref, $size - $part, $countdown - 1);
} ## --- end sub _poisson_dist

## --- end class Quality
