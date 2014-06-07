#!/usr/bin/env perl
use strict; use warnings;
use rlib '../lib';
use Test::More;

use_ok $_ for qw(
    Term::ReadLine::Perl5::OO
);

done_testing;
