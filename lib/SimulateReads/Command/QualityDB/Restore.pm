#
#===============================================================================
#
#         FILE: Restore.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07-09-2017 22:48:26
#     REVISION: ---
#===============================================================================

package SimulateReads::Command::QualityDB::Restore;

use My::Base 'class';

extends 'SimulateReads::Command::QualityDB';

sub opt_spec {
	'help|h',
	'man|M',
	'verbose|v'
}

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {}

sub execute {
	my ($self, $opts, $args) = @_;
	$LOG_VERBOSE = exists $opts->{verbose} ? $opts->{verbose} : 0;
	log_msg "Restoring quality database to vendor state ...";
	$self->restoredb;
	log_msg "Done!";
}

__END__

=head1 NAME

simulate_reads - Creates single-end and paired-end fastq reads for transcriptome and genome simulation 

=head1 SYNOPSIS

 simulate_reads qualitydb restore

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages

=head1 DESCRIPTION

B<simulate_reads> will read the given input file and do something
useful with the contents thereof.

=head1 AUTHOR

Thiago Miller - L<tmiller@mochsl.org.br>

=cut
