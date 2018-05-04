package App::SimulateReads::Fastq::SingleEnd;
# ABSTRACT: App::SimulateReads::Fastq subclass for simulate single-end fastq entries.

use App::SimulateReads::Base 'class';
use App::SimulateReads::Read::SingleEnd;

extends 'App::SimulateReads::Fastq';

with 'App::SimulateReads::Role::RunTimeTemplate';

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
	isa        => 'App::SimulateReads::Read::SingleEnd',
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
	App::SimulateReads::Read::SingleEnd->new(
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
		'%t' => '$info->{start}',
		'%n' => '$info->{end}',
		'%i' => '$info->{instrument}',
		'%I' => '$info->{id}',
		'%R' => '$info->{read}',
		'%U' => '$info->{num}',
		'%s' => '$info->{strand}',
		'%x' => '$info->{error}'
	);

	return  $self->compile_template($self->template_id, 'info', \%sym_table);
}

sub _build_info {
	my $self = shift;

	my %info = (
#		instrument       => sprintf("SR%d", getppid),
		instrument       => 'SR',
		quality_profile  => $self->quality_profile,
		read_size        => $self->read_size,
		sequencing_error => $self->sequencing_error
	);

	return \%info;
}

sub sprint_fastq {
	my ($self, $id, $num, $seq_id, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read_ref, $pos, $errors_a) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my ($start, $end) = ($pos + 1, $pos + $self->read_size);

	unless ($is_leader) {
		($start, $end) = ($end, $start);
	}

	# Set defaut sequencing errors
	my $errors = 'none';

	# Set errors if there are sequencing errors
	if (@$errors_a) {
		$errors = join ","
			=> map { sprintf "%d:%s/%s" => $_->{pos} + 1, $_->{b}, $_->{not_b} }
			@$errors_a;
	}

	$self->_set_info(
		'id'     => $id,
		'num'    => $num,
		'seq_id' => $seq_id,
		'start'  => $start,
		'end'    => $end,
		'read'   => 1,
		'strand' => $is_leader ? 'P' : 'M',
		'error'  => $errors
	);

	my $gen_header = $self->_gen_header;
	my $header = $gen_header->($self->_info);

	return $self->fastq_template(\$header, $read_ref);
}
