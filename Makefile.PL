use inc::Module::Install;

name 'Simulate-Reads';
author 'Thiago Miller';
version '0.01';
license 'GPL';

requires 'Moose';
requires 'Math::Random';
auto_install;

test_requires 'Test::Most'  => 0.35;
test_requires 'Test::Class' => 0.50;

install_share;
install_script 'simulate_reads';

WriteAll;
