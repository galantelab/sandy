package App::Sandy::Seq;
# ABSTRACT: Base class to simulate seq entries

use App::Sandy::Base 'class';
use App::Sandy::Quality;

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

has 'quality_profile' => (
	is         => 'ro',
	isa        => 'My:QualityP',
	required   => 1,
	coerce     => 1
);

has 'read_size' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 1
);

has '_quality' => (
	is         => 'ro',
	isa        => 'App::Sandy::Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => [qw{ gen_quality }]
);

has '_sym_table' => (
	is         => 'ro',
	isa        => 'HashRef[Str]',
	builder    => '_build_sym_table',
	lazy_build => 1
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_quality;
}

sub _build_sym_table {
	my $sym_table = {
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
	};

	return $sym_table;
}

sub _build_gen_header {
	my $self = shift;
	my $sym_table = $self->_sym_table;
	return $self->with_compile_template($self->template_id, 'info', $sym_table);
}

sub _build_info {
	my $self = shift;

	my $info = {
		instrument       => 'SR',
		quality_profile  => $self->quality_profile,
		read_size        => $self->read_size,
		sequencing_error => $self->sequencing_error
	};

	return $info;
}

sub _build_quality {
	my $self = shift;
	App::Sandy::Quality->new(
		quality_profile => $self->quality_profile,
		read_size       => $self->read_size
	);
}

sub fastq_template {
	my ($self, $header_ref, $seq_ref) = @_;
	my $quality_ref = $self->gen_quality;

	my $fastq = "\@$$header_ref\n";
	$fastq .= "$$seq_ref\n";
	$fastq .= "+\n";
	$fastq .= "$$quality_ref";

	return \$fastq;
}
