use inc::Module::Install;

# Define metadata
name           'Simulate-Reads';
abstract       'Creates single-end and paired-end fastq reads for transcriptome and genome simulation';
author         'Thiago Miller';
version        '0.01';
license        'GPL';

# Specific dependencies
requires        'Moose'                     => 2.2005;
requires        'MooseX::StrictConstructor' => 0.21;
requires        'MooseX::UndefTolerant'     => 0.21;
requires        'namespace::autoclean'      => 0.28;
requires        'true'                      => 0.18;
requires        'Math::Random'              => 0.72;
requires        'Try::Tiny'                 => 0.28;
requires        'Carp'                      => 1.38;
requires        'File::Cat'                 => 1.20;
requires        'File::Path'                => 2.09;
requires        'Path::Class'               => 0.37;
requires        'Scalar::Util'              => 1.47;
requires        'Storable'                  => 2.51;
requires        'Parallel::ForkManager'     => 1.19;
requires        'PerlIO::gzip'              => 0.19;
requires        'IO::Compress::Gzip'        => 2.074;
requires        'IO::Uncompress::Gunzip'    => 2.074;
requires        'Getopt::Long'              => 2.39;
requires        'Pod::Usage'                => 1.69;
requires        'Hook::AfterRuntime'        => 0.005;
requires        'Import::Into'              => 1.002005;
requires        'Data::OptList'             => 0.110;
requires        'Module::Runtime'           => 0.015;
requires        'DBI'                       => 1.637;
requires        'DBD::SQLite'               => 1.54;
requires        'DBIx::Class'               => 0.082840;

test_requires   'Test::Most'                => 0.35;
test_requires   'Test::Class'               => 0.50;
test_requires   'Test::Perl::Critic'        => 1.03;
test_requires   'Class::Data::Inheritable'  => 0.08;

# Install data
install_script 'simulate_reads';
install_share;
auto_install;

WriteAll;
