package App::Sandy::Fastq::SingleEnd;
# ABSTRACT: App::Sandy::Fastq subclass for simulate single-end fastq entries.

use App::Sandy::Base 'class';
use App::Sandy::Read::SingleEnd;

extends 'App::Sandy::Fastq';

with 'App::Sandy::Role::RunTimeTemplate';

# VERSION

has 'template_id' => (
	is         => 'ro',
	isa        => 'Str',
	required   => 1
);

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has '_gen_header' => (
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_gen_header',
	lazy_build => 1
);

has '_info' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[Str]',
	builder    => '_build_info',
	lazy_build => 1,
	handles    => {
		_set_info => 'set',
		_get_info => 'get'
	}
);

has '_read' => (
	is         => 'ro',
	isa        => 'App::Sandy::Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_read;
}

sub _build_read {
	my $self = shift;
	App::Sandy::Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size
	);
}

sub _build_gen_header {
	my $self = shift;
	my %sym_table = (
		'%q' => '$info->{quality_profile}',
		'%r' => '$info->{read_size}',
		'%e' => '$info->{sequencing_error}',
		'%c' => '$info->{seq_id}',
		'%C' => '$info->{seq_id_type}',
		'%a' => '$info->{start_ref}',
		'%b' => '$info->{end_ref}',
		'%t' => '$info->{start}',
		'%n' => '$info->{end}',
		'%i' => '$info->{instrument}',
		'%I' => '$info->{id}',
		'%R' => '$info->{read}',
		'%U' => '$info->{num}',
		'%s' => '$info->{strand}',
		'%x' => '$info->{error}',
		'%v' => '$info->{var}'
	);

	return  $self->with_compile_template($self->template_id, 'info', \%sym_table);
}

sub _build_info {
	my $self = shift;

	my %info = (
		instrument       => 'SR',
		quality_profile  => $self->quality_profile,
		read_size        => $self->read_size,
		sequencing_error => $self->sequencing_error
	);

	return \%info;
}

sub sprint_fastq {
	my ($self, $id, $num, $seq_id, $seq_id_type, $ptable, $ptable_size, $is_leader) = @_;

	my ($read_ref, $attr) = $self->gen_read($ptable, $ptable_size, $is_leader);

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

	my $gen_header = $self->_gen_header;
	my $header = $gen_header->($self->_info);

	return $self->fastq_template(\$header, $read_ref);
}
