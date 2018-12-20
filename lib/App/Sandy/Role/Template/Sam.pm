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
	SAM_VERSION   => '1.0'
};

our $VERSION = '0.22'; # VERSION

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
	my $single_end = UNMAP;
	my $read1 = PAIRED|UNMAP|MUNMAP|READ1;
	my $read2 = PAIRED|UNMAP|MUNMAP|READ2;
	return [$single_end, $read1, $read2];
}

sub with_eof_marker {
	my $eof = pack("C28",
		0x1f, 0x8b, 0x08, 0x04, 0x00, 0x00, 0x00, 0x00,
		0x00, 0xff, 0x06, 0x00, 0x42, 0x43, 0x02, 0x00,
		0x1b, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
		0x00, 0x00, 0x00, 0x00
	);
	return \$eof;
}

sub with_sam_header_template {
	my ($self, $argv) = @_;
	my $cl = "sandy @$argv";

	## no critic
	my $vn = do { no strict 'vars'; $VERSION || "dev" };
	## use critic

	my $header = sprintf "\@HD\tVN:%s\tSO:queryname\n\@PG\tID:%s\tPN:%s\tVN:%s\tCL:%s\n"
		=> SAM_VERSION, 'sandy', 'sandy', $vn, $cl;

	return \$header;
}

sub with_sam_align_template {
	my ($self, $seqid_ref, $read_ref, $quality_ref, $read_flag) = @_;

	my $sam = sprintf "%s\t%d\t*\t0\t0\t*\t*\t0\t0\t%s\t%s\n"
		=> $$seqid_ref, $self->_get_flag($read_flag), $$read_ref, $$quality_ref;

	return \$sam;
}

sub with_bam_header_template {
	my ($self, $argv) = @_;
	my $header_ref = $self->with_sam_header_template($argv);

	my $l_text = length($$header_ref);
	my $block = pack("c4l<", 66, 65, 77, 1, $l_text) . $$header_ref . pack("l<", 0);

	return \$block;
}

sub with_bam_align_template {
	my ($self, $seqid_ref, $read_ref, $quality_ref, $read_flag, $read_size) = @_;

	# Catch the seqid size nul padded
	my $seqid_size = length($$seqid_ref) + 1;

	# Encode all bases in 4 bits 0-15 (hex 0x0-0xf) and
	# pack the codes to high level nibbles
	my $packed_read = pack("H*",
		$$read_ref =~ tr [=ACMGRSVTWYHKDBNacmgrsvtwyhkdbn\x00-\xff] [\x00-\x0f\x01-\x0f]r);

	# quality to ascii and calculate the phred score [!-~]
	my $packed_quality = $$quality_ref =~ tr [\x21-\x7e\x00-\xff] [\x00-\x5d\x00]r;

	# Calculate the total block size in bytes
	my $block_size = $seqid_size + $read_size + int(($read_size + 1) / 2) + 32;

	# Lets set this align block
	my $block = pack("l<3C2S<3l<4",
		$block_size,
		-1,
		-1,
		$seqid_size,
		0,
		4680,
		0,
		$self->_get_flag($read_flag),
		$read_size,
		-1,
		-1,
		0
	);

	# Cat the seqid, read and quality packs to block
	$block .= $$seqid_ref . pack("x") . $packed_read . $packed_quality;
	return \$block;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Role::Template::Sam - Sam template role

=head1 VERSION

version 0.22

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Felipe R. C. dos Santos <fsantos@mochsl.org.br>

=item *

Helena B. Conceição <hconceicao@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
