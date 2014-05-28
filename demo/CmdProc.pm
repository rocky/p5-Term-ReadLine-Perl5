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
    my($class)  = @_;
    my $self = {
	num_cols => $num_cols,
        class    => $class,
    };
    bless $self, $class;
    $self->load_cmds_initialize;
    $self;
}

%commands = (
    'ResetTTY'          => \&Cmd::cmd_ResetTTY,
    'SetTTY'            => \&Cmd::cmd_SetTTY,
    'exit'              => \&Cmd::cmd_exit,
    'help'              => \&Cmd::cmd_help,
    'init'              => \&Cmd::cmd_init,
    'preinit'           => \&Cmd::cmd_preinit,
    'read_an_init_file' => \&Cmd::cmd_read_an_init_file,
    'redisplay'         => \&Cmd::cmd_redisplay,
    'rl_filename_list'  => \&Cmd::cmd_rl_filename_list,
    'rl_set'            => \&Cmd::cmd_rl_set,
    'tilde_complete'    => \&Cmd::cmd_tilde_complete
    );

@commands = sort keys %commands;

1;
