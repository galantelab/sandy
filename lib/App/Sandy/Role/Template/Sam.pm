package App::Sandy::Role::Template::Sam;
# ABSTRACT: Sam template role

use App::Sandy::Base 'role';

use constant {
	PAIRED        => 0x1,
	PROPER_PAIR   => 0x2,
	UNMAP         => 0x4,
	MUNMAP        => 0x8,
	REVERSE       => 0x10,
	MREVERSE      => 0x20,
	READ1         => 0x40,
	READ2         => 0x80,
	SECONDARY     => 0x100,
	QCFAIL        => 0x200,
	DUP           => 0x400,
	SUPPLEMENTARY => 0x800,
	SAM_VERSION   => 1.5
};

# VERSION

has '_flags' => (
	traits     => ['Array'],
	is         => 'ro',
	isa        => 'ArrayRef',
	builder    => '_build_flags',
	lazy_build => 1,
	handles    => {
		_get_flag => 'get'
	}
);

sub _build_flags {
	my $single_end = 0x0;
	my $read1 = PAIRED|UNMAP|MUNMAP|READ1;
	my $read2 = PAIRED|UNMAP|MUNMAP|READ2;
	return [$single_end, $read1, $read2];
}

sub with_sam_header_template {
	my ($self, $sample_name, $read_group, $argv) = @_;
	my $cl = "@$argv";

	## no critic
	my $vn = do { no strict 'vars'; $VERSION || "dev" };
	## use critic

	my $header = sprintf "\@HD\tVN:%f\tSO:unsorted\n\@RG\tID:%s\tSM:%s\n\@PG\tID:%s\tPN:%s\tCL:%s\tDS:%s\tVN:%s"
		=> SAM_VERSION, $read_group, $sample_name, 'SANDY', 'sandy', $cl, 'simulation', $vn;

	return \$header;
}

sub with_sam_align_template {
	my ($self, $seqid_ref, $read_ref, $quality_ref, $read_flag, $read_group) = @_;
	my $bam = sprintf "%s\t%d\t*\t0\t0\t*\t*\t0\t0\t%s\t%s\tRG:Z:%s"
		=> $$seqid_ref, $self->_get_flag($read_flag), $$read_ref, $$quality_ref, $read_group;
	return \$bam;
}
