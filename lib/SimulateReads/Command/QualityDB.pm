#
#===============================================================================
#
#         FILE: QualityDB.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 09/06/2017 03:46:25 PM
#     REVISION: ---
#===============================================================================

package SimulateReads::Command::QualityDB;

use My::Base 'class';
use Quality::Handle;

has 'db' => (
	is         => 'ro',
	isa        => 'Quality::Handle',
	builder    => '_build_db',
	lazy_build => 1,
	handles    => [qw/insertdb restoredb deletedb make_report/]
);

sub _build_db {
	return Quality::Handle->new;
}

sub opt_spec {
	'help|h',
	'man|M'
}

sub subcommand_map {
	add     => 'SimulateReads::Command::QualityDB::Add',
	remove  => 'SimulateReads::Command::QualityDB::Remove',
	restore => 'SimulateReads::Command::QualityDB::Restore'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	my ($self, $opts, $args) = @_;
	return $self->_print_report;
}

sub _print_report {
	my $self = shift;
	my $report_ref = $self->make_report;
	return if not defined $report_ref;

	my $format = "\t%*s\t%*s\t%*s\t%*s\n";
	my ($s1, $s2, $s3, $s4) = map {length} qw/sequencing_system/x4;
	printf $format => $s1, "sequencing system", $s2, "size", $s3, "source", $s4, "provider";

	for my $sequencing_system (sort keys %$report_ref) {
		my $attr = $report_ref->{$sequencing_system};
		for my $entry (sort { $a->{size} <=> $b->{size} } @$attr) {
			printf $format => $s1, $sequencing_system, $s2, $entry->{size}, $s3, $entry->{source}, $s4, $entry->{provider};
		}
	}
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

=head1 SYNOPSIS

 simulate_reads qualitydb
 simulate_reads qualitydb [options]
 simulate_reads qualitydb <command>

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
 
 Subcommands:
  add                      add a new quality profile to database
  remove                   remove an user quality profle from database
  restore                  restore the database

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
