#!/usr/bin/env perl
use strict;
use warnings;
use rlib '../lib';

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl5' );
}

require 'Term/ReadLine/readline.pm';
ok(defined($Term::ReadLine::Perl5::VERSION),
   "\$Term::ReadLine::Perl5::Version number is set");

# stop reading ~/.inputrc
$ENV{'INPUTRC'} = '/dev/null';

note('ctrl()');
is(readline::ctrl(ord('A')), 1);
is(readline::ctrl(ord('a')), 1);

done_testing();
