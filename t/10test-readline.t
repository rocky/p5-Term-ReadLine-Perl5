# -*- perl -*-
#	readline.t - Test script for Term::ReadLine:Perl
#
#  Adapted from readline.t of Term::ReadLine::Gnu
#	Copyright (c) 2010 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.

use strict; use warnings;
use lib './lib';
use Test::More;

BEGIN {
    $ENV{PERL_RL} = 'Perl';	# force to use Term::ReadLine::Perl
    $ENV{LANG} = 'C';
}

use Term::ReadLine::Perl;

my $verbose = defined @ARGV && ($ARGV[0] eq 'verbose');


########################################################################
# test new method

$ENV{'INPUTRC'} = '/dev/null';	# stop reading ~/.inputrc

my $t = new Term::ReadLine::Perl 'ReadLineTest';
ok($t, "new method, new's");

my $OUT;
if ($verbose) {
    $OUT = $t->OUT;
} else {
    open(NULL, '>/dev/null') or die "cannot open \`/dev/null\': $!\n";
    $OUT = \*NULL;
    $t->Attribs->{outstream} = \*NULL;
}

########################################################################
# test ReadLine method

is($t->ReadLine, 'Term::ReadLine::Perl',
   "Package name should be 'Term::ReadLine::Perl'");

########################################################################
# test Features method

my %features = %{ $t->Features };
my $res = %features;
ok($res, 'Got Features method');

done_testing();
