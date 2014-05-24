#!/usr/bin/env perl
# The intent here is to have something for folks to play with to show
# off Term::ReadLine::Perl5. Down the line, what would be nice is
# to have a command-line interface for showing/changing readline
# functions.
use strict; use warnings;
use rlib './lib';

use Term::ReadLine::Perl5;
use Array::Columnize;
use Term::ReadKey;

print "================================================\n";
print "Welcome to the Term::ReadLine::Perl5 demo shell!\n";
print "================================================\n";

my $term = new Term::ReadLine::Perl5 'Perl5 shell';
my ($num_cols,$num_rows) =  Term::ReadKey::GetTerminalSize(\*STDOUT);

my @features = sort keys %{ $term->Features; };
print "Features:\n";
print Array::Columnize::columnize(\@features,
				  {displaywidth => $num_cols,
				   colsep => ' ',
				   lineprefix => '  '});
print "Type 'exit' to leave.\n";
print "Entered lines are echoed and put into history.\n";
print "Default completion is by OS filename\n";

my $initfile = '.inputrc';
if (Term::ReadLine::Perl5::readline::read_an_init_file($initfile)) {
    print "$initfile loaded\n";
};
my $prompt = "shell> ";
while ( defined (my $line = $term->readline($prompt)) )
{
    chomp $line;
    last if $line eq 'exit';
    print $line, "\n";
    no warnings 'once';
    $term->addhistory($line) if $line =~ /\S/
	and !$Term::ReadLine::Perl5::features{autohistory};
    $readline::rl_default_selected = !$readline::rl_default_selected;
}
$Term::ReadLine::Perl5::DEBUG = 0;
