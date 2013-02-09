#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use blib;

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl' );
}

require 'Term/ReadLine/readline.pm';
ok(defined($Term::ReadLine::Perl::VERSION), 
   "\$Term::ReadLine::Perl::Version number is set");

# stop reading ~/.inputrc
$ENV{'INPUTRC'} = '/dev/null';

note('ctrl()');
is(readline::ctrl(ord('A')), 1);
is(readline::ctrl(ord('a')), 1);
done_testing();

