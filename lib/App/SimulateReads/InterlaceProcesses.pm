package App::SimulateReads::InterlaceProcesses;
# ABSTRACT: Interlaces the processe id for differents processes, actually for parent, child processes.

use App::SimulateReads::Base 'class';

our $VERSION = '0.05'; # VERSION

#-------------------------------------------------------------------------------
#  Static variables
#-------------------------------------------------------------------------------
my $SIGNAL_ACM = 0;
my @SIGNALS_RECEIVED;

has 'foreign_pid' => (is => 'ro', isa => 'ArrayRef[Int]', required => 1);

#===  CLASS METHOD  ============================================================
#        CLASS: InterlaceProcesses
#       METHOD: BUILD (Moose)
#   PARAMETERS: Void
#      RETURNS: Void
#  DESCRIPTION: Trap signals
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub BUILD {
	my $self = shift;

	$SIG{TERM} = $self->_handle_signal;
	$SIG{INT}  = $self->_handle_signal;
	$SIG{QUIT} = $self->_handle_signal;
} ## --- end sub BUILD

#===  CLASS METHOD  ============================================================
#        CLASS: InterlaceProcesses
#       METHOD: signal_catched
#   PARAMETERS: Void
#      RETURNS: Int >= 0
#  DESCRIPTION: Returns the number of times it receives a termination signal
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub signal_catched {
	return $SIGNAL_ACM;
} ## --- end sub signal_catched

#===  CLASS METHOD  ============================================================
#        CLASS: InterlaceProcesses
#       METHOD: signal_received
#   PARAMETERS: Void
#      RETURNS: Str
#  DESCRIPTION: Returns a string with the signal names received
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub signal_received {
	return join(", " => @SIGNALS_RECEIVED);
} ## --- end sub signal_received

#===  CLASS METHOD  ============================================================
#        CLASS: InterlaceProcesses
#       METHOD: _handle_signal (PRIVATE)
#   PARAMETERS: Void
#      RETURNS: Ref Code
#  DESCRIPTION: Sets a handler to trapping signal. If termination signal is received
#               it kills the interlaced processes
#       THROWS: no exceptions
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub _handle_signal {
	my $self = shift;
	return sub {
		my $signame = shift;
		push @SIGNALS_RECEIVED => $signame;
		$SIGNAL_ACM++;
		my $cnt = kill 'TERM' => @{ $self->foreign_pid };
	};
} ## --- end sub _handle_signal

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::InterlaceProcesses - Interlaces the processe id for differents processes, actually for parent, child processes.

=head1 VERSION

version 0.05

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
