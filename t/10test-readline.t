# -*- perl -*-
#	readline.t - Test script for Term::ReadLine:Perl
#
#  Adapted from readline.t of Term::ReadLine::GNU
#	Copyright (c) 2010 Hiroo Hayashi.  All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.

BEGIN {
    my $last = 4; #104
    print "1..$last\n"; $n = 1;
    $ENV{PERL_RL} = 'Perl';	# force to use Term::ReadLine::Perl
    $ENV{LANG} = 'C';
}
END {print "not ok 1\tfail to load\n" unless $loaded;}

my $verbose = defined @ARGV && ($ARGV[0] eq 'verbose');

use strict; use warnings;
use vars qw($loaded $n);
use lib './blib';
use Term::ReadLine;

# Perl-5.005 and later has Test.pm, but I define this here to support
# older version.
my $res;
my $ok = 1;
sub ok {
    my $what = shift || '';

    if ($res) {
	print "ok $n\t$what\n";
    } else {
	print "not ok $n\t$what";
	print @_ ? "\t@_\n" : "\n";
	$ok = 0;
    }
    $n++;
}
$loaded = 1;
print "ok 1\tloading\n"; $n++;

########################################################################
# test new method

$ENV{'INPUTRC'} = '/dev/null';	# stop reading ~/.inputrc

my $t = new Term::ReadLine 'ReadLineTest';
$res =  defined $t; ok('new');

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

$res = $t->ReadLine eq 'Term::ReadLine::Perl';
ok('ReadLine method',
   "\tPackage name should be \`Term::ReadLine::Perl\', but it is \`",
   $t->ReadLine, "\'\n");

########################################################################
# test Features method

my %features = %{ $t->Features };
$res = %features;
ok('Features method',"\tNo additional features present.\n");

