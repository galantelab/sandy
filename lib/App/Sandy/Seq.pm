package App::Sandy::Seq;
# ABSTRACT: Base class to simulate seq entries

use App::Sandy::Base 'class';
use App::Sandy::Quality;

use constant NUM_TRIES => 1000;

with qw{
	App::Sandy::Role::RunTimeTemplate
	App::Sandy::Role::Template::Fastq
	App::Sandy::Role::Template::Sam
	App::Sandy::Role::RNorm
};

our $VERSION = '0.22'; # VERSION

has 'format' => (
	is         => 'ro',
	isa        => 'My:Format',
	required   => 1
);

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

has 'quality_profile' => (
	is         => 'ro',
	isa        => 'My:QualityP',
	required   => 1,
	coerce     => 1
);

has 'read_mean' => (
	is         => 'ro',
	isa        => 'My:IntGt0',
	required   => 1
);

has 'read_stdd' => (
	is         => 'ro',
	isa        => 'My:IntGe0',
	required   => 1
);

has '_template_id' => (
	traits     => ['Code'],
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_template_id',
	lazy_build => 1,
	handles    => {
		_gen_id => 'execute'
	}
);

has '_template_seq' => (
	traits     => ['Code'],
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_template_seq',
	lazy_build => 1,
	handles    => {
		_gen_seq => 'execute'
	}
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

has '_read_size' => (
	traits     => ['Code'],
	is         => 'ro',
	isa        => 'CodeRef',
	builder    => '_build_read_size',
	lazy_build => 1,
	handles    => {
		_get_read_size => 'execute'
	}
);

has '_quality' => (
	is         => 'ro',
	isa        => 'App::Sandy::Quality',
	builder    => '_build_quality',
	lazy_build => 1,
	handles    => ['gen_quality']
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
		'%m' => '$info->{read_mean}',
		'%d' => '$info->{read_stdd}',
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

sub _build_template_id {
	my $self = shift;
	my $sym_table = $self->_sym_table;
	return $self->with_compile_template($self->template_id, 'info', $sym_table);
}

sub _build_template_seq {
	my $self = shift;

	my $format = $self->format;
	my $gen_seq;

	if ($format =~ /fastq/) {
		$gen_seq = sub { $self->with_fastq_template(@_) };
	} elsif ($format eq 'sam') {
		$gen_seq = sub { $self->with_sam_align_template(@_) };
	} elsif ($format eq 'bam') {
		$gen_seq = sub { $self->with_bam_align_template(@_) };
	} else {
		croak "No valid format: '$format'";
	}

	return $gen_seq;
}

sub _build_info {
	my $self = shift;

	my $info = {
		instrument       => 'SR',
		quality_profile  => $self->quality_profile,
		sequencing_error => $self->sequencing_error,
		read_mean        => $self->read_mean,
		read_stdd        => $self->read_stdd
	};

	return $info;
}

sub _build_read_size {
	my $self = shift;
	my $fun;

	if ($self->read_stdd == 0) {
		$fun = sub { $self->read_mean };
	} else {
		$fun = sub {
			my $size = 0;
			my $random_tries = 0;
			until ($size > 0) {
				if (++$random_tries > NUM_TRIES) {
					croak "So many tries to calculate a seq size greater than zero ...";
				}
				$size = $self->with_random_half_normal($self->read_mean,
					$self->read_stdd)
			}
			return $size;
		};
	}

	return $fun;
}

sub _build_quality {
	my $self = shift;
	App::Sandy::Quality->new(
		quality_profile => $self->quality_profile
	);
}

sub gen_sam_header {
	my ($self, $argv) = @_;
	my $format = $self->format;
	my $header;

	if ($format eq 'sam') {
		$header = $self->with_sam_header_template($argv);
	} elsif ($format eq 'bam') {
		$header = $self->with_bam_header_template($argv);
	} else {
		croak "No valid format: '$format'";
	}

	return $header;
}

sub gen_eof_marker {
	my ($self, $file) = @_;

	open my $fh, ">>" => $file
		or croak "Cannot open '$file': $!";

	binmode $fh;

	my $eof_ref = $self->with_eof_marker;
	print {$fh} $$eof_ref;

	close $fh
		or croak "Cannot write to '$file': $!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Seq - Base class to simulate seq entries

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
