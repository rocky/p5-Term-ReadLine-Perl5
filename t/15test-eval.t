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
is(join(',', readline::_unescape("foo")), '102,111,111');
is(join(',', readline::_unescape("f\x74o\x723")), '102,116,111,114,51');
is(join(',', readline::_unescape("f\x74o\x723\0777f\x23d\0555")), '102,116,111,114,51,63,55,102,35,100,45,53');

done_testing();

