package App::Sandy::Seq::PairedEnd;
# ABSTRACT: App::Sandy::Seq subclass for simulate paired-end entries.

use App::Sandy::Base 'class';
use App::Sandy::Read::PairedEnd;

extends 'App::Sandy::Seq';

our $VERSION = '0.23'; # VERSION

has 'fragment_mean' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 1
);

has 'fragment_stdd' => (
	is         => 'ro',
	isa        => 'My:IntGe0',
	required   => 1
);

has '_read' => (
	is         => 'ro',
	isa        => 'App::Sandy::Read::PairedEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => ['gen_read']
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_read;
}

sub _build_read {
	my $self = shift;
	App::Sandy::Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);
}

override '_build_sym_table' => sub {
	my $self = shift;
	my $sym_table = super();

	my %sym_table_paired_end = (
		'%M' => '$info->{fragment_mean}',
		'%D' => '$info->{fragment_stdd}',
		'%f' => '$info->{fragment_size}',
		'%S' => '$info->{fragment_start}',
		'%E' => '$info->{fragment_end}',
		'%X' => '$info->{fragment_start_ref}',
		'%Z' => '$info->{fragment_end_ref}',
		'%F' => '$info->{fragment_strand}',
		'%A' => '$info->{mate_start_ref}',
		'%B' => '$info->{mate_end_ref}',
		'%T' => '$info->{mate_start}',
		'%N' => '$info->{mate_end}',
		'%L' => '$info->{tlen}',
	);

	@$sym_table{keys %sym_table_paired_end} = values %sym_table_paired_end;
	return $sym_table;
};

override '_build_info' => sub {
	my $self = shift;
	my $info = super();

	my %info_paired_end = (
		fragment_mean => $self->fragment_mean,
		fragment_stdd => $self->fragment_stdd
	);

	@$info{keys %info_paired_end} = values %info_paired_end;
	return $info;
};

sub sprint_seq {
	my ($self, $id, $num, $seq_id, $seq_id_type, $ptable, $ptable_size, $is_leader) = @_;

	my $read_size = $self->_get_read_size;

	# In order to work third gen sequencing
	# simulator, it is necessary to truncate
	# the read according to the ptable size
	if ($read_size > $ptable_size) {
		$read_size = $ptable_size;
	}

	my ($read1_ref, $read2_ref, $attr) = $self->gen_read($ptable, $ptable_size,
		$read_size, $is_leader);

	my $annot_a = $attr->{annot};

	$self->_set_info(
		'id'                 => $id,
		'num'                => $num,
		'seq_id'             => $seq_id,
		'seq_id_type'        => $seq_id_type,
		'read_size'          => $read_size,
		'fragment_start'     => $attr->{start},
		'fragment_end'       => $attr->{end},
		'fragment_start_ref' => $attr->{start_ref},
		'fragment_end_ref'   => $attr->{end_ref},
		'fragment_size'      => $attr->{end} - $attr->{start} + 1,
		'fragment_strand'    => $is_leader ? 'P' : 'M',
		'var'                => @$annot_a ? join ',' => @$annot_a : 'none'
	);

	return $is_leader
		? ($self->_sprint_seq($read1_ref, $read_size, 1, $attr, 1), $self->_sprint_seq($read2_ref, $read_size, 2, $attr, 0))
		: ($self->_sprint_seq($read2_ref, $read_size, 1, $attr, 0), $self->_sprint_seq($read1_ref, $read_size, 2, $attr, 1));
}

sub _sprint_seq {
	my ($self, $read_ref, $read_size, $read_num, $attr, $is_leader) = @_;

	if ($is_leader) {
		my $error_a = $attr->{error1};
		my $tlen = $attr->{end2} - $attr->{end1};

		$self->_set_info(
			'start'          => $attr->{start1},
			'end'            => $attr->{end1},
			'start_ref'      => $attr->{start_ref},
			'end_ref'        => $attr->{read_end_ref},
			'mate_start'     => $attr->{start2},
			'mate_end'       => $attr->{end2},
			'mate_start_ref' => $attr->{end_ref},
			'mate_end_ref'   => $attr->{read_start_ref},
			'read'           => $read_num,
			'strand'         => 'P',
			'tlen'           => $tlen > 0 ? $tlen : 0,
			'error'          => @$error_a ? join ',' => @$error_a : 'none'
		);
	} else {
		my $error_a = $attr->{error2};
		my $tlen = $attr->{end1} - $attr->{end2};

		$self->_set_info(
			'start'          => $attr->{start2},
			'end'            => $attr->{end2},
			'start_ref'      => $attr->{end_ref},
			'end_ref'        => $attr->{read_start_ref},
			'mate_start'     => $attr->{start1},
			'mate_end'       => $attr->{end1},
			'mate_start_ref' => $attr->{start_ref},
			'mate_end_ref'   => $attr->{read_end_ref},
			'read'           => $read_num,
			'strand'         => 'M',
			'tlen'           => $tlen < 0 ? $tlen : 0,
			'error'          => @$error_a ? join ',' => @$error_a : 'none'
		);
	}

	my $seqid = $self->_gen_id($self->_info);
	my $quality_ref = $self->gen_quality($read_size);

	return $self->_gen_seq(\$seqid, $read_ref, $quality_ref, $read_num, $read_size);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Seq::PairedEnd - App::Sandy::Seq subclass for simulate paired-end entries.

=head1 VERSION

version 0.23

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

Rodrigo Barreiro <rbarreiro@mochsl.org.br>

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
