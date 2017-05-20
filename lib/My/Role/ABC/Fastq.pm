#
#===============================================================================
#
#         FILE: Fastq.pm
#
#  DESCRIPTION: 'Fastq' abstract class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 20-05-2017 15:40:16
#     REVISION: ---
#===============================================================================

package My::Role::ABC::Fastq;

use Moose::Role;
use MooseX::Params::Validate;
use My::Types;
 
requires 'fastq';

before 'fastq' => sub {
	my $self = shift;
	my ($id, $seq_name, $seq, $seq_size, $is_leader) = pos_validated_list(
		\@_,
		{ isa => 'Str | Int'      },
		{ isa => 'Str'            },
		{ isa => 'ScalarRef[Str]' },
		{ isa => 'My:IntGt0'      },
		{ isa => 'Bool'           }
	);
};

1;
