package App::SimulateReads::Fastq::PairedEnd;
# ABSTRACT: App::SimulateReads::Fastq subclass for simulate paired-end fastq entries.

use App::SimulateReads::Base 'class';
use App::SimulateReads::Read::PairedEnd;

extends 'App::SimulateReads::Fastq';

with 'App::SimulateReads::Role::RunTimeTemplate';

# VERSION

has 'template_id' => (
	is         => 'ro',
	isa        => 'Str',
	required   => 1
);

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

has 'sequencing_error' => (
	is         => 'ro',
	isa        => 'My:NumHS',
	required   => 1
);

has '_read' => (
	is         => 'ro',
	isa        => 'App::SimulateReads::Read::PairedEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => [qw{ gen_read }]
);

has '_gen_header' => (
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_gen_header',
	lazy_build => 1
);

has '_info1' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[Str]',
	builder    => '_build_info',
	lazy_build => 1,
	handles    => {
		_set_info1 => 'set',
		_get_info1 => 'get'
	}
);

has '_info2' => (
	traits     => ['Hash'],
	is         => 'ro',
	isa        => 'HashRef[Str]',
	builder    => '_build_info',
	lazy_build => 1,
	handles    => {
		_set_info2 => 'set',
		_get_info2 => 'get'
	}
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_read;
}

sub _build_read {
	my $self = shift;
	App::SimulateReads::Read::PairedEnd->new(
		sequencing_error => $self->sequencing_error,
		read_size        => $self->read_size,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);
}

sub _build_gen_header {
	my $self = shift;
	my %sym_table = (
		'%q' => '$info->{quality_profile}',
		'%r' => '$info->{read_size}',
		'%e' => '$info->{sequencing_error}',
		'%m' => '$info->{fragment_mean}',
		'%d' => '$info->{fragment_stdd}',
		'%f' => '$info->{fragment_size}',
		'%S' => '$info->{fragment_start}',
		'%E' => '$info->{fragment_end}',
		'%c' => '$info->{seq_id}',
		'%t' => '$info->{start}',
		'%n' => '$info->{end}',
		'%T' => '$info->{mate_start}',
		'%N' => '$info->{mate_end}',
		'%D' => '$info->{tlen}',
		'%i' => '$info->{instrument}',
		'%I' => '$info->{id}',
		'%R' => '$info->{read}',
		'%U' => '$info->{num}',
		'%s' => '$info->{strand}',
		'%x' => '$info->{error}'
	);

#	return  $self->compile_template('%i.%U %U simulation_read length=%r position=%c:%t-%n distance=%D', 'info', \%sym_table);
	return  $self->compile_template($self->template_id, 'info', \%sym_table);
}

sub _build_info {
	my $self = shift;

	my %info = (
#		instrument       => sprintf("SR%d", getppid),
		instrument       => 'SR',
		quality_profile  => $self->quality_profile,
		read_size        => $self->read_size,
		sequencing_error => $self->sequencing_error,
		fragment_mean    => $self->fragment_mean,
		fragment_stdd    => $self->fragment_stdd
	);

	return \%info;
}

sub sprint_fastq {
	my ($self, $id, $num, $seq_id, $seq_ref, $seq_size, $is_leader) = @_;

	my ($read1_ref, $errors1_a, $read2_ref, $errors2_a, $fragment_pos, $fragment_size) = $self->gen_read($seq_ref, $seq_size, $is_leader);

	my ($fragment_start, $fragment_end) = ($fragment_pos + 1, $fragment_pos + $fragment_size);

	my ($start1, $end1) = ($fragment_start, $fragment_start + $self->read_size - 1);
	my ($start2, $end2) = ($fragment_end, $fragment_end - $self->read_size + 1);

	unless ($is_leader) {
		($start1, $end1, $start2, $end2) = ($start2, $end2, $start1, $end1);
	}

	# Set defaut sequencing errors for R1
	my $errors1 = 'none';

	# Set errors if there are sequencing errors for R1
	if (@$errors1_a) {
		$errors1 = join ","
			=> map { sprintf "%d:%s/%s" => $_->{pos} + 1, $_->{b}, $_->{not_b} }
			@$errors1_a;
	}

	# Set defaut sequencing errors for R2
	my $errors2 = 'none';

	# Set errors if there are sequencing errors for R2
	if (@$errors2_a) {
		$errors2 = join ","
			=> map { sprintf "%d:%s/%s" => $_->{pos} + 1, $_->{b}, $_->{not_b} }
			@$errors2_a;
	}

	$self->_set_info1(
		'id'               => $id,
		'num'              => $num,
		'fragment_size'    => $fragment_size,
		'fragment_start'   => $fragment_start,
		'fragment_end'     => $fragment_end,
		'seq_id'           => $seq_id,
		'start'            => $start1,
		'end'              => $end1,
		'mate_start'       => $start2,
		'mate_end'         => $end2,
		'tlen'             => $end2 - $end1,
		'read'             => 1,
		'strand'           => $is_leader ? 'P' : 'M',
		'error'            => $errors1
	);

	$self->_set_info2(
		'id'               => $id,
		'num'              => $num,
		'fragment_size'    => $fragment_size,
		'fragment_start'   => $fragment_start,
		'fragment_end'     => $fragment_end,
		'seq_id'           => $seq_id,
		'start'            => $start2,
		'end'              => $end2,
		'mate_start'       => $start1,
		'mate_end'         => $end1,
		'tlen'             => $end1 - $end2,
		'read'             => 2,
		'strand'           => $is_leader ? 'P' : 'M',
		'error'            => $errors2
	);

	my $gen_header = $self->_gen_header;
	my $header1 = $gen_header->($self->_info1);
	my $header2 = $gen_header->($self->_info2);

	my $fastq1_ref = $self->fastq_template(\$header1, $read1_ref);
	my $fastq2_ref = $self->fastq_template(\$header2, $read2_ref);

	return ($fastq1_ref, $fastq2_ref);
}
