#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use blib;

use Test::More;

BEGIN {
use_ok( 'Term::ReadLine' );
}

ok(defined($Term::ReadLine::VERSION), 
   "\$Term::ReadLine::Version number is set");
done_testing();

