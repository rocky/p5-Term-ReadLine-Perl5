#!/usr/bin/env perl
# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
# The intent here is to have something for folks to play with to show
# off Term::ReadLine::Perl5. Down the line, what would be nice is
# to have a command-line interface for showing/changing readline
# functions.
# use Enbugger 'trepan';
use strict; use warnings;
use rlib '../lib';

use Term::ReadLine::Perl5;
use Term::ReadKey;
use Data::Printer;

use rlib '.';
use CmdProc;

END{
    print "That's all folks!...\n";
    Term::ReadLine::Perl5::readline::ResetTTY;
}

my $term = new Term::ReadLine::Perl5 'Term::ReadLine::Perl5 shell';
my $attribs = $term->Attribs;

my $cmdproc = CmdProc->new($term);
my @commands = sort keys %{$cmdproc->{commands}};

sub command_completion($$$) {
  my ($text, $line, $start) = @_;
  return () if $start != 0;
  grep(/^$text/, @commands);
}

print "================================================\n";
print "Welcome to the Term::ReadLine::Perl5 demo shell!\n";
print "================================================\n";

# Silence "used only once warnings" inside ReadLine::Term::Perl.
no warnings 'once';
$attribs->{completion_function} = \&command_completion;

print "\nType 'help' for help, and 'exit' to leave.\n";
print "Entered lines are echoed and put into history.\n";

my $initfile = '.inputrc';
if (Term::ReadLine::Perl5::readline::read_an_init_file($initfile)) {
    print "$initfile loaded\n";
};

$Term::ReadLine::Perl5::preput = 0;

my $prompt = 'shell> ';
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
	my $cmd = $cmdproc->{commands}{$command};
	if ($cmd) {
	    # FIXME: Add
            # if ($self->ok_for_running($cmd, $command, scalar(@args)-1)) 	    &$fn(@args); {  ... }
	    $cmd->run(\@args);
	} else {
	    print "You typed:\n$line\n";
	}
    }
    no warnings 'once';
    $term->addhistory($line) if $line =~ /\S/
	and !$Term::ReadLine::Perl5::features{autohistory};
    $readline::rl_default_selected = !$readline::rl_default_selected;
}

$Term::ReadLine::Perl5::DEBUG = 0;
