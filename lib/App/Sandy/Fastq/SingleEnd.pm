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

	my ($read_ref, $read_pos, $pos, $errors_a, $annot_a) = $self->gen_read($ptable,
		$ptable_size, $is_leader);

	my ($start, $end) = ($read_pos + 1, $read_pos + $self->read_size);
	my ($start_ref, $end_ref) = ($pos + 1, $pos + $self->read_size);

	unless ($is_leader) {
		($start, $end) = ($end, $start);
		($start_ref, $end_ref) = ($end_ref, $start_ref);
	}

	# Set defaut sequencing errors
	my $errors = 'none';

	# Set errors if there are sequencing errors
	if (@$errors_a) {
		$errors = join ","
			=> map { sprintf "%d:%s/%s" => $_->{pos} + 1, $_->{b}, $_->{not_b} }
			@$errors_a;
	}

	# Set default structural variation
	my $var = 'none';

	# Set variation if any
	if (@$annot_a) {
		$var = join ","
			=> map { sprintf "%d:%s/%s" => $_->{pos} + 1, $_->{ref}, $_->{alt} }
			@$annot_a;
	}

	$self->_set_info(
		'id'          => $id,
		'num'         => $num,
		'seq_id'      => $seq_id,
		'start'       => $start,
		'end'         => $end,
		'start_ref'   => $start_ref,
		'end_ref'     => $end_ref,
		'read'        => 1,
		'strand'      => $is_leader ? 'P' : 'M',
		'error'       => $errors,
		'var'         => $var,
		'seq_id_type' => $seq_id_type
	);

	my $gen_header = $self->_gen_header;
	my $header = $gen_header->($self->_info);

	return $self->fastq_template(\$header, $read_ref);
}
