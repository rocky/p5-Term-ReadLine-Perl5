# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Array::Columnize;
use rlib '../../lib';
package Cmd::help;

use rlib '.';
use if !@ISA, Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 0;      # Need at least this many
use constant MAX_ARGS  => undef;  # Need at most this many - undef -> unlimited.
EOE
}

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<help>

=head2 Examples:

   help

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    print "Commands:\n";
    print Array::Columnize::columnize(\@commands,
				      {displaywidth => $proc->{num_cols},
				       colsep => '  ',
				      });
}

unless (caller) {
    require CmdProc;
    my $proc = CmdProc->new;
    $proc->{num_cols} = 30;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, 'help', 'rl_set', 'SetTTY']);
}

1;
