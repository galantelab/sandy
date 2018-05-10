package App::Sandy::Types;
# ABSTRACT: Moose type constraints for App::Sandy project

use Moose::Util::TypeConstraints;

# VERSION

subtype 'My:IntGt0'
	=> as      'Int'
	=> where   { $_ > 0 }
	=> message { "Value must be an integer greater than zero, not '$_'" };

subtype 'My:IntGe0'
	=> as      'Int'
	=> where   { $_ >= 0 }
	=> message { "Value must be an integer greater or equal to zero, not '$_'" };

subtype 'My:NumGt0'
	=> as      'Num'
	=> where   { $_ > 0 }
	=> message { "Value must be a number greater than zero, not '$_'" };

subtype 'My:NumGe0'
	=> as      'Num'
	=> where   { $_ >= 0 }
	=> message { "Value must be a number greater or equal to zero, not '$_'" };

subtype 'My:NumHS'
	=> as      'Num'
	=> where   { $_ >= 0 && $_ <= 1 }
	=> message { "Value must be a number between zero and one, not '$_'" };

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

subtype 'My:QualityP'
	=> as      'Str';

coerce 'My:QualityP'
	=> from    'Str'
	=> via     { lc $_ };

subtype 'My:QualityH'
	=> as      'HashRef'
	=> where   { exists $_->{matrix} && exists $_->{deepth} }
	=> message { "'$_' is not a valid quality hash" };

subtype 'My:IdFa'
	=> as      'HashRef'
	=> where   { exists $_->{seq} && exists $_->{size} }
	=> message { "'$_' is not a valid fasta id" };

subtype 'My:IdxFasta'
	=> as      'HashRef[My:IdFa]'
	=> message { "'$_' is not a valid indexed fasta" };

subtype 'My:StrandBias'
	=> as      'Str'
	=> where   { $_ eq 'plus' || $_ eq 'minus' || $_ eq 'random' }
	=> message { "'$_' is not a valid strand-bias: 'plus', 'minus' or 'random'" };

subtype 'My:SeqIdWeight'
	=> as      'Str'
	=> where   { $_ eq 'length' || $_ eq 'same' || $_ eq 'count' }
	=> message { "'$_' is not a valid seqid-weight: 'length', 'same' or 'count'" };

subtype 'My:SeqType'
	=> as      'Str'
	=> where   { $_ eq 'single-end' || $_ eq 'paired-end' }
	=> message { "'$_' is not a valid sequencing-type: 'single-end' or 'paired-end'" };

subtype 'My:CountLoopBy'
	=> as      'Str'
	=> where   { $_ eq 'coverage' || $_ eq 'number-of-reads' }
	=> message { "'$_' is not a valid count_loops_by: 'coverage' or 'number-of-reads'" };

subtype 'My:Piece'
	=> as      'HashRef'
	=> where   { exists $_->{ref} && exists $_->{start} && exists $_->{len} && exists $_->{pos} }
	=> message { "Invalid piece inserted to piece_table" };

subtype 'My:PieceTable'
	=> as      'HashRef'
	=> where   {exists $_->{size} && exists $_->{table} && ref $_->{table} eq 'App::Sandy::PieceTable'}
	=> message { "Invalid piece table entry" };

1; ## --- end class App::Sandy::Types
