#!/usr/bin/env perl
# The intent here is to have something for folks to play with to show
# off Term::ReadLine::Perl5. Down the line, what would be nice is
# to have a command-line interface for showing/changing readline
# functions.
use strict; use warnings;
use rlib '../lib';

use Term::ReadLine::Perl5;
use Term::ReadKey;
use Data::Printer;

use rlib '.';
use Cmd qw(@commands %commands);

END{
    print "That's all folks!...\n";
    Term::ReadLine::Perl5::readline::ResetTTY;
}

sub command_completion($$$) {
  my ($text, $line, $start) = @_;
  return () if $start != 0;
  grep(/^$text/, @Cmd::commands);
}

print "================================================\n";
print "Welcome to the Term::ReadLine::Perl5 demo shell!\n";
print "================================================\n";

my $term = new Term::ReadLine::Perl5 'Term::ReadLine::Perl5 shell';
my $attribs = $term->Attribs;

Cmd::print_features($term);

# Silence "used only once warnings" inside ReadLine::Term::Perl.
no warnings 'once';
$attribs->{completion_function} = \&command_completion;

print "\n"; Cmd::cmd_help();
print "\nType 'exit' to leave.\n";
print "Entered lines are echoed and put into history.\n";

my $initfile = '.inputrc';
if (Term::ReadLine::Perl5::readline::read_an_init_file($initfile)) {
    print "$initfile loaded\n";
};

$Term::ReadLine::Perl5::preput = 0;

my $prompt = "shell> ";
while ( defined (my $line = $term->readline($prompt)) )
{
    ### FIXME do this in a more general way.
    chomp $line;
    my @args = split(/[ \t]/, $line);
    next unless @args;
    my $command = $args[0];
    if ($command eq 'exit') {
	last;
    } else {
	my $fn = $Cmd::commands{$command};
	if ($fn) {
	    &$fn(@args);
	} else {
	    print $line, "\n";
	}
    }
    no warnings 'once';
    $term->addhistory($line) if $line =~ /\S/
	and !$Term::ReadLine::Perl5::features{autohistory};
    $readline::rl_default_selected = !$readline::rl_default_selected;
}

$Term::ReadLine::Perl5::DEBUG = 0;
