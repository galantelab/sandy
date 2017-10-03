package App::SimulateReads::Read::SingleEnd;
# ABSTRACT: App::SimulateReads::Read subclass for simulate single-end reads.

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Read';

our $VERSION = '0.05'; # VERSION

#===  CLASS METHOD  ============================================================
#        CLASS: Read::SingleEnd
#       METHOD: gen_read
#   PARAMETERS: $seq_ref Ref Str, $seq_size Int > 0, $is_leader Bool
#      RETURNS: $read_ref Ref Str, $read_pos Int >= 0
#  DESCRIPTION: Generate single-end read
#       THROWS: If $seq_size less then read_size, throws an error message
#     COMMENTS: none
#     SEE ALSO: n/a
#===============================================================================
sub gen_read {
	my ($self, $seq_ref, $seq_size, $is_leader) = @_;
	# seq_size must be greater or equal to read_size
	if ($seq_size < $self->read_size) {
		croak "Single-end read fail: The constraints were not met:\n" .
			  "seq_size ($seq_size) >= read_size (" . $self->read_size . ")\n";
	}

	my ($read_ref, $read_pos) = $self->subseq_rand($seq_ref, $seq_size, $self->read_size);

	unless ($is_leader) {
		$self->reverse_complement($read_ref);
	}

	$self->update_count_base($self->read_size);
	$self->insert_sequencing_error($read_ref);
	return ($read_ref, $read_pos);
} ## --- end sub gen_read

__END__

=pod

=encoding UTF-8

=head1 NAME

App::SimulateReads::Read::SingleEnd - App::SimulateReads::Read subclass for simulate single-end reads.

=head1 VERSION

version 0.05

=head1 AUTHOR

Thiago L. A. Miller <tmiller@mochsl.org.br>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
