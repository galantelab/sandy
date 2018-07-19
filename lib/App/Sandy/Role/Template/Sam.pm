package App::Sandy::Role::Template::Sam;
# ABSTRACT: Sam template role

use App::Sandy::Base 'role';
use List::Util 'pairs';

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
	SAM_VERSION   => 1.0
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

has '_base_encoding' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef',
	builder    => '_build_base_encoding',
	lazy_build => 1,
	handles    => {
		_get_base_encoding => 'get'
	}
);

sub _build_flags {
	my $single_end = UNMAP;
	my $read1 = PAIRED|UNMAP|MUNMAP|READ1;
	my $read2 = PAIRED|UNMAP|MUNMAP|READ2;
	return [$single_end, $read1, $read2];
}

sub _build_base_encoding {
	my $bases = {
		'=' => 0,  'A' => 1,  'C' => 2,  'M' => 3,
		'G' => 4,  'R' => 5,  'S' => 6,  'V' => 7,
		'T' => 8,  'W' => 9,  'Y' => 10, 'H' => 11,
		'K' => 12, 'D' => 13, 'B' => 14, 'N' => 15,
		'a' => 1,  'c' => 2,  'm' => 3,  '0' => 0,
		'g' => 4,  'r' => 5,  's' => 6,  'v' => 7,
		't' => 8,  'w' => 9,  'y' => 10, 'h' => 11,
		'k' => 12, 'd' => 13, 'b' => 14, 'n' => 15
	};
	return $bases;
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

	my $header = sprintf "\@HD\tVN:%s\tSO:unsorted\n\@PG\tID:%s\tPN:%s\tVN:%s\tCL:%s\n"
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

	# Pack the read
	my ($packed_read, $pack_size) = $self->_pack_read($read_ref, $read_size);

	# quality to ascii and calculate the phred score
	my @ascii = unpack("C*", $$quality_ref);
	for my $phred (@ascii) {
		$phred -= 33;
	}

	# Calculate the total block size in bytes
	my $block_size = (32 * 2 + 8 * 2 + 16 * 3 + 32 * 4 + $seqid_size * 8 + $pack_size * 8 + $read_size * 8) / 8;

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
		0,
	);

	# Cat the seqid, read and quality packs to block
	$block .= $$seqid_ref . pack("x") . $$packed_read . pack("c*", @ascii);
	return \$block;
}

sub _pack_read {
	my ($self, $read_ref, $read_size) = @_;

	my @base_codes =
		map { $self->_get_base_encoding($_) || 15 }
		unpack("(A)*", $$read_ref);

	push @base_codes => 0 if $read_size % 2;

	my @bytes;
	for my $pair (pairs @base_codes) {
		my ($code1, $code2) = @$pair;
		$code1 <<= 4;
		$code1 |= $code2;
		push @bytes => $code1;
	}

	my $packed_read = pack("C*", @bytes);
	return (\$packed_read, int(($read_size + 1) / 2));
}
