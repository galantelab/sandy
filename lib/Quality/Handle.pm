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
 
my $db_fn = file(__FILE__)->dir->parent->parent->file('share', 'quality_profile.db');

has 'schema' => (
	is         => 'ro',
	isa        => 'Quality::Schema',
	builder    => '_build_schema',
	lazy_build => 1,
);

sub _build_schema {
	#TODO Check if quality_profile exists into an array of options
	return Quality::Schema->connect("dbi:SQLite:$db_fn", "", "", { RaiseError => 1, PrintError => 0 });
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
