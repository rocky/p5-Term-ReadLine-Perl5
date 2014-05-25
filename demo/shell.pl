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
use DemoHelper qw(@commands %commands);

END{
    print "That's all folks!...\n";
    Term::ReadLine::Perl5::readline::ResetTTY;
}

sub command_completion($$$) {
  my ($text, $line, $start) = @_;
  return () if $start != 0;
  grep(/^$text/, @DemoHelper::commands);
}

print "================================================\n";
print "Welcome to the Term::ReadLine::Perl5 demo shell!\n";
print "================================================\n";

my $term = new Term::ReadLine::Perl5 'Term::ReadLine::Perl5 shell';
my $attribs = $term->Attribs;

DemoHelper::print_features($term);

# Silence "used only once warnings" inside ReadLine::Term::Perl.
no warnings 'once';
$attribs->{completion_function} = \&command_completion;

print "\n"; DemoHelper::cmd_help();
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
    if ($command eq 'tilde_complete') {
	my $prefix = (@args == 1) ? '~': $args[1];
	if (substr($prefix, 0, 1) ne '~') {
	    print "Tilde expansion expected to start with ~\n";
	} else {
	    $prefix = substr($prefix, 1);
	    my @matches =
		Term::ReadLine::Perl5::readline::tilde_complete($prefix);
	    p @matches;
	}
    } elsif ($command eq 'rl_filename_list') {
	my @matches =
	    Term::ReadLine::Perl5::readline::rl_filename_list($args[1]);
	p @matches;
    } elsif ($command eq 'read_an_init_file') {
	my $filename = $args[1];
	my $result =
	    Term::ReadLine::Perl5::readline::read_an_init_file($filename);
	if ($result) {
	    print "File $filename read ok\n";
	} else {
	    print "File $filename did not read ok\n";
	}
    } elsif ($command eq 'rl_set') {
	if (@args != 3) {
	    printf "Was expecting exactly two args, got %d\n", $#args;
	} else  {
	    Term::ReadLine::Perl5::readline::rl_set($args[1], $args[2]);
	}
    } elsif ($command eq 'exit') {
	last;
    } else {
	my $fn = $DemoHelper::commands{$command};
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
