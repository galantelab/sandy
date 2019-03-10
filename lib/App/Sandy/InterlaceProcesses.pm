package App::Sandy::InterlaceProcesses;
# ABSTRACT: Interlaces the processe id for differents processes, actually for parent, child processes.

use App::Sandy::Base 'class';

our $VERSION = '0.23'; # VERSION

has 'foreign_pid' => (
	is       => 'ro',
	isa      => 'ArrayRef[Int]',
	required => 1
);

has '_signal_stack' => (
	traits   => ['Array'],
	is       => 'ro',
	isa      => 'ArrayRef[Str]',
	default  => sub { [] },
	handles  => {
		_add_signal           => 'push',
		signal_catched        => 'count',
		join_signals_received => 'join'
	}
);

sub BUILD {
	my $self = shift;
	$SIG{TERM} = $self->_handle_signal;
	$SIG{INT}  = $self->_handle_signal;
	$SIG{QUIT} = $self->_handle_signal;
}

sub _handle_signal {
	my $self = shift;
	return sub {
		my $signame = shift;
		unless ($self->signal_catched) {
			$self->_add_signal($signame);
			my $cnt = kill 'TERM' => @{ $self->foreign_pid };
		}
	};
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::InterlaceProcesses - Interlaces the processe id for differents processes, actually for parent, child processes.

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
