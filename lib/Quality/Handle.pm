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
use Storable qw/nfreeze thaw/;
use Path::Class 'file';
 
my $db_fn = file(__FILE__)->dir->parent->parent->file('share', 'quality_profile.db');

has 'schema' => (
	is         => 'ro',
	isa        => 'Quality::Schema',
	builder    => '_build_schema',
	lazy_build => 1,
);

sub _build_schema {
	return Quality::Schema->connect("dbi:SQLite:$db_fn", "", "", { RaiseError => 1, PrintError => 0 });
}

sub report {
	my $self = shift;
	my $schema = $self->schema;
	my $report;

	my $quality_rs = $schema->resultset('Quality')->search(
		undef,
		{
			order_by => [{ -asc => 'sequencing_system.name' }, { -asc => 'size'}],
			prefetch => ['sequencing_system']
		}
	);

	my $format = "\t%*s\t%*s\t%*s\n";
	my ($s1, $s2, $s3) = map {length} qw/sequencing_system/x3;

	$report = sprintf $format => $s1, "sequencing system", $s2, "size", $s3, "source"
		if $quality_rs;

	while (my $quality = $quality_rs->next) {
		my $sequencing_system = $quality->sequencing_system->name;
		my $size = $quality->size;
		my $source = $quality->source;
		$return .= sprintf $format => $s1, $sequencing_system, $s2, $size, $s3, $source;
	}

	return $report;
}
