#!/usr/bin/env perl 

use strict;
use warnings;

use Test::Perl::Critic (-profile => "perlcritic.ini") x!! -e "perlcritic.ini";
all_critic_ok();
