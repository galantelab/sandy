package App::Sandy::Role::Template::Fastq;
# ABSTRACT: Fastq template role

use App::Sandy::Base 'role';

# VERSION

sub with_fastq_template {
	my ($self, $seqid_ref, $read_ref, $quality_ref) = @_;
	my $fastq = "\@$$seqid_ref\n$$read_ref\n+\n$$quality_ref\n";
	return \$fastq;
}
