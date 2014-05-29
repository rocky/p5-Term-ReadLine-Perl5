# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
# A command processor. This includes is a manager for the commands
use strict; use warnings;
use Exporter;
use Array::Columnize;
use File::Basename;
use Term::ReadKey;

package CmdProc;
use Data::Printer;

use English qw( -no_match_vars );

use rlib '../lib';
use Term::ReadLine::Perl5;
use rlib '.';
use Cmd;
use Load;

my ($num_cols,$num_rows) =  Term::ReadKey::GetTerminalSize(\*STDOUT);

sub new($$) {
    my($class, $term)  = @_;
    my $self = {
	num_cols => $num_cols,
        class    => $class,
	term     => $term,
    };
    bless $self, $class;
    $self->load_cmds_initialize;
    $self;
}

1;
