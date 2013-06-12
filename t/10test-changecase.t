#!/usr/bin/env perl
use strict;
use warnings;
use rlib '../lib';

use Test::More;

BEGIN {
  use_ok( 'Term::ReadLine::Perl5' );
}

require 'Term/ReadLine/readline.pm';

# stop reading ~/.inputrc
$ENV{'INPUTRC'} = '/dev/null';

$readline::_rl_japanese_mb = 0;
$readline::line = 'xyz123 XYZ 012z MiXedCase ABCt !@#$%{}';
$readline::D    = 0;
note("F_Upcase");
readline::F_UpcaseWord(1);
is($readline::line, 'XYZ123 XYZ 012z MiXedCase ABCt !@#$%{}');
readline::F_UpcaseWord(2);
is($readline::line, 'XYZ123 XYZ 012Z MiXedCase ABCt !@#$%{}');

note("F_Downcase");
$readline::D    = 0;
readline::F_DownCaseWord(1);
is($readline::line, 'xyz123 XYZ 012Z MiXedCase ABCt !@#$%{}');
readline::F_DownCaseWord(2);
is($readline::line, 'xyz123 xyz 012z MiXedCase ABCt !@#$%{}');

note("F_CapitalizeWord");
$readline::D    = 0;
readline::F_CapitalizeWord(1);
is($readline::line, 'Xyz123 xyz 012z MiXedCase ABCt !@#$%{}');
readline::F_CapitalizeWord(2);
is($readline::line, 'Xyz123 Xyz 012Z MiXedCase ABCt !@#$%{}');

done_testing();
