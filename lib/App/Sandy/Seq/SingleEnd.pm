package App::Sandy::Seq::SingleEnd;
# ABSTRACT: App::Sandy::Seq subclass for simulate single-end entries.

use App::Sandy::Base 'class';
use App::Sandy::Read::SingleEnd;

extends 'App::Sandy::Seq';

our $VERSION = '0.21'; # VERSION

has '_read' => (
	is         => 'ro',
	isa        => 'App::Sandy::Read::SingleEnd',
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
	App::Sandy::Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error
	);
}

sub sprint_seq {
	my ($self, $id, $num, $seq_id, $seq_id_type, $ptable, $ptable_size, $is_leader) = @_;

	my $read_size = $self->_get_read_size;

	# In order to work third gen sequencing
	# simulator, it is necessary to truncate
	# the read according to the ptable size
	if ($read_size > $ptable_size) {
		$read_size = $ptable_size;
	}

	my ($read_ref, $attr) = $self->gen_read($ptable, $ptable_size, $read_size, $is_leader);

	my $error_a = $attr->{error};
	my $error = @$error_a
		? join ',' => @$error_a
		: 'none';

	my $annot_a = $attr->{annot};
	my $var = @$annot_a
		? join ',' => @$annot_a
		: 'none';

	$self->_set_info(
		'id'          => $id,
		'num'         => $num,
		'seq_id'      => $seq_id,
		'read'        => 1,
		'error'       => $error,
		'var'         => $var,
		'seq_id_type' => $seq_id_type,
		'read_size'   => $read_size,
		$is_leader
			? (
				'start'     => $attr->{start},
				'end'       => $attr->{end},
				'start_ref' => $attr->{start_ref},
				'end_ref'   => $attr->{end_ref},
				'strand'    => 'P')
			: (
				'start'     => $attr->{end},
				'end'       => $attr->{start},
				'start_ref' => $attr->{end_ref},
				'end_ref'   => $attr->{start_ref},
				'strand'    => 'M')
	);

	my $seqid = $self->_gen_id($self->_info);
	my $quality_ref = $self->gen_quality($read_size);

	return $self->_gen_seq(\$seqid, $read_ref, $quality_ref, 0, $read_size);
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Seq::SingleEnd - App::Sandy::Seq subclass for simulate single-end entries.

=head1 VERSION

version 0.21

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
