# -*- perl -*-

use strict; use warnings;

# Note: we don't use Helper here. Should we?
use rlib '../lib';
use Test::More;

BEGIN {
    $ENV{PERL_RL} = 'Perl5';	# force to use Term::ReadLine::Perl5
    $ENV{LANG} = 'C';
    $ENV{'COLUMNS'} = 80;
    $ENV{'LINES'} = 25;
    # stop reading ~/.inputrc
    $ENV{'INPUTRC'} = '/dev/null';
}

sub run_filename_list($) {
    my $pat = shift;
    my @results  = Term::ReadLine::Perl5::readline::rl_filename_list($pat);
    foreach my $file (@results) {
	ok(-e $file, "returned $file should exist")
    }
    return @results;
}

use Cwd;
use Term::ReadLine::Perl5;


my $verbose = @ARGV && ($ARGV[0] eq 'verbose');
my @results;

note('rl_filename_list');

@results  = run_filename_list(cwd);
ok(@results, "should get a result expanding cwd");

@results  = run_filename_list(__FILE__);
cmp_ok(scalar @results, '>', 0, 'Get at least one expansion');
is($results[0], __FILE__, 'First entry should match what we passed in');

note('Assume that whoever is logged in to run this has a home directory');
my $name = getpwuid($<); my $tilde_name = '~' . $name;

@results  = run_filename_list($tilde_name);
cmp_ok(scalar(@results), '==', 1, "Expansion for my login $tilde_name");

my @results2  = run_filename_list('~');
is_deeply(\@results2, \@results,
	  "Expanding ~ should be the same as $tilde_name");

done_testing();
