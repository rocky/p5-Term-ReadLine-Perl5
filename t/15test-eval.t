#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl5' );
}

use rlib '../lib';
require 'Term/ReadLine/readline.pm';

# stop reading ~/.inputrc
$ENV{'INPUTRC'} = '/dev/null';

note('_unescape()');
my %tests = (
    "foo" => [qw(102 111 111)],
    "f\x74o\x723" => [qw(102 116 111 114 51)],
    "f\x74o\x723\0777f\x23d\0555" => [qw(102 116 111 114 51 63 55 102 35 100 45 53)],
    'f\\C-\\M-f' => [qw(102 27 6)],
    'f\\C-\\M-d' => [qw(102 27 4)],
    'f\\C-d' => [qw(102 4)],
    'f\\C-x' => [qw(102 24)],
    'f\\C-a' => [qw(102 1)],
    'f\\C-r' => [qw(102 18)],
    'f\\C-rq' => [qw(102 18 113)],
    'q\\x0fDr' => [qw(113 15 68 114)],
    '\\e' => [qw(27)],
    '\\M-f' => [qw(27 102)],
    'f\\M-a' => [qw(102 27 97)],
    'r\\xdd' => [qw(114 221)],
    'r\\xddd' => [qw(114 221 100)],
    'rd\\0330\\dfe3' => [qw(114 100 27 48 4 102 101 51)],
    'rd\\0330\\dfe3\\xfdd' => [qw(114 100 27 48 4 102 101 51 253 100)],
    '\\*' => [qw(default)],
    '\\0333foo\\*' => [qw(27 51 102 111 111 default)],
    '\\d' => [qw(4)],
    'fo\\d' => [qw(102 111 4)],
    'fo\\d\\b' => [qw(102 111 4 127)],
    '\\adf\\n\\r\\w\\w\\f\\a\\effffff' => [qw(7 100 102 10 13 119 119 12 7 27 102 102 102 102 102 102)],
);

foreach my $test (keys %tests) {
    is_deeply([ readline::_unescape($test) ], $tests{$test});
}

done_testing();

