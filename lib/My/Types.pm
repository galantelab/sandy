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

subtype 'My:Weight'
	=> as      'HashRef'
	=> where   { exists $_->{down} && exists $_->{up} && exists $_->{feature} }
	=> message { "'$_' is not a Weight object" };

subtype 'My:Weights'
	=> as 'ArrayRef[My:Weight]'
	=> message { "'$_' is not a Weight object array" };

1;
