use inc::Module::Install;

# Define metadata
name           'Simulate-Reads';
abstract       'Creates single-end and paired-end fastq reads for transcriptome and genome simulation';
author         'Thiago Miller';
version        '0.01';
license        'GPL';

# Specific dependencies
requires       'Moose'                     => 2.2005;
requires       'MooseX::StrictConstructor' => 0.21;
requires       'namespace::autoclean'      => 0.28;
requires       'Math::Random'              => 0.72;
requires       'Try::Tiny'                 => 0.28;
requires       'Carp'                      => 1.38;
requires       'File::Basename'            => 2.85;
requires       'File::Spec'                => 3.63;
requires       'File::Cat'                 => 1.20;
requires       'Scalar::Util'              => 1.48;
requires       'Storable'                  => 2.56;
requires       'Parallel::ForkManager'     => 1.19;
requires       'PerlIO::gzip'              => 0.19;
test_requires  'Test::Most'                => 0.35;
test_requires  'Test::Class'               => 0.50;

# Install data
install_script 'simulate_reads';
install_share;
auto_install;

WriteAll;
