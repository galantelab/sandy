use inc::Module::Install;

name 'Simulate-Reads';
author 'Thiago Miller';
version '0.01';
license 'GPL';

requires 'Moose';
requires 'Math::Random';
auto_install;

install_share;
install_script 'simulate_reads';

WriteAll;
