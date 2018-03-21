package App::SimulateReads::Command::Simulate::Transcriptome;
# ABSTRACT: simulate subcommand class. Simulate transcriptome sequencing

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::Command::Simulate';

with 'App::SimulateReads::Role::Digest';

# VERSION

sub default_opt {
	'verbose'          => 0,
	'prefix'           => 'out',
	'output-dir'       => '.',
	'jobs'             => 1,
	'gzip'             => 1,
	'count-loops-by'   => 'number-of-reads',
	'number-of-reads'  => 1000000,
	'strand-bias'      => 'minus',
	'seqid-weight'     => 'length',
	'sequencing-type'  => 'paired-end',
	'fragment-mean'    => 300,
	'fragment-stdd'    => 50,
	'sequencing-error' => 0.005,
	'read-size'        => 101,
	'quality-profile'  => 'hiseq'
}

__END__
