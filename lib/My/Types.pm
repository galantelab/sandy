#
#===============================================================================
#
#         FILE: Types.pm
#
#  DESCRIPTION: Type constraints
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller
# ORGANIZATION: IEP - Hospital Sírio-Libanês
#      VERSION: 1.0
#      CREATED: 19-05-2017 21:00:05
#     REVISION: ---
#===============================================================================

package My::Types;
 
use Moose::Util::TypeConstraints;

subtype 'My:IntGt0'
	=> as      'Int'
	=> where   { $_ > 0 } 
	=> message { "Value must be greater than zero, not $_" };

subtype 'My:IntGe0'
	=> as      'Int'
	=> where   { $_ >= 0 } 
	=> message { "Value must be greater or equal to zero, not $_" };

subtype 'My:NumGt0'
	=> as      'Num'
	=> where   { $_ > 0 } 
	=> message { "Value must be greater than zero, not $_" };

subtype 'My:NumGe0'
	=> as      'Num'
	=> where   { $_ >= 0 } 
	=> message { "Value must be greater or equal to zero, not $_" };

subtype 'My:NumHS'
	=> as      'Num'
	=> where   { $_ >= 0 && $_ <= 1 }
	=> message { "Value must be between zero and one, not $_" };

subtype 'My:File'
	=> as      'Str'
	=> where   { -f $_ }
	=> message { "'$_' must be a file" };

subtype 'My:Fasta'
	=> as      'My:File'
	=> where   { $_ =~ /.+\.(fasta|fa|fna|ffn)(\.gz)*$/ }
	=> message { "'$_' must be a fasta file: Check the extension (.fasta, .fa, .fna, .ffn - compressed, or not, by gzip, as in .fasta.gz etc)" };

subtype 'My:Weight'
	=> as      'HashRef'
	=> where   { exists $_->{down} && exists $_->{up} && exists $_->{feature} }
	=> message { "'$_' is not a Weight object" };

subtype 'My:Weights'
	=> as      'ArrayRef[My:Weight]'
	=> message { "'$_' is not a Weight object array" };

subtype 'My:SeqSys'
	=> as      'Str'
	=> where   { $_ eq 'hiseq' }
	=> message { "'$_' is not a valid sequencing system" };

coerce 'My:SeqSys'
	=> from    'Str'
	=> via     { lc $_ };

subtype 'My:QualityH'
	=> as      'HashRef'
	=> where   { exists $_->{mtx} && exists $_->{len} }
	=> message { "$_ is not a valid quality hash" };

subtype 'My:StrandBias'
	=> as      'Str'
	=> where   { $_ eq 'plus' || $_ eq 'minus' || $_ eq 'random' }
	=> message { "$_ is not a valid strand_bias: 'plus', 'minus' or 'random'" };

subtype 'My:SeqWeight'
	=> as      'Str'
	=> where   { $_ eq 'length' || $_ eq 'same' || $_ eq 'file' }
	=> message { "$_ is not a valid sequence_weight: 'length', 'same' or 'file'" };

subtype 'My:CountLoopBy'
	=> as      'Str'
	=> where   { $_ eq 'coverage' || $_ eq 'number_of_reads' }
	=> message { "$_ is not a valid count_loops_by: 'coverage' or 'number_of_reads'" };

1;
