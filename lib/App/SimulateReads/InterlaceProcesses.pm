package App::SimulateReads::InterlaceProcesses;
# ABSTRACT: Interlaces the processe id for differents processes, actually for parent, child processes.

use App::SimulateReads::Base 'class';

# VERSION

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
		$self->_add_signal($signame);
		my $cnt = kill 'TERM' => @{ $self->foreign_pid };
	};
}
