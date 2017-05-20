#
#===============================================================================
#
#         FILE: Read.pm
#
#  DESCRIPTION: 'Read' abstract class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 20-05-2017 15:56:29
#     REVISION: ---
#===============================================================================

package My::Role::ABC::Read;

use Moose::Role;
use MooseX::Params::Validate;

requires 'gen_read';

before 'gen_read' => sub {
	my $self = shift;
	my ($seq, $seq_size, $is_leader) = pos_validated_list(
		\@_,
		{ isa => 'ScalarRef[Str]' },
		{ isa => 'My:IntGt0'      },
		{ isa => 'Bool'           }
	);
};
 
1;
