package App::Sandy::RNG;
# ABSTRACT: Generates random numbers

use 5.018000;
use strict;
use warnings;

require Exporter;

# VERSION

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ('all' => [ qw() ]);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw();

require XSLoader;
XSLoader::load('App::Sandy::RNG', $VERSION);

# Preloaded methods go here.

1;
