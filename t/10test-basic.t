#!/usr/bin/env perl
use strict; use warnings;
use rlib '.'; use Helper;

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl5' );
}

ok(defined($Term::ReadLine::Perl5::VERSION),
   "\$Term::ReadLine::Perl5::Version number is set");

note('ctrl()');
is(readline::ctrl(ord('A')), 1);
is(readline::ctrl(ord('a')), 1);

done_testing();
