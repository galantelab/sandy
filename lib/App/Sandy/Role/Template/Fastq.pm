package App::Sandy::Role::Template::Fastq;
# ABSTRACT: Fastq template role

use App::Sandy::Base 'role';

sub with_fastq_template {
	my ($self, $header_ref, $read_ref, $quality_ref) = @_;
	my $fastq = "\@$$header_ref\n$$read_ref\n+\n$$quality_ref";
	return \$fastq;
}
