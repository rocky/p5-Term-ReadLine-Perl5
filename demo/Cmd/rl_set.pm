# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use rlib '../../lib';
package Cmd::rl_set;

use rlib '.';
use if !@ISA, Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 2;  # Need at least this many
use constant MAX_ARGS  => 2;  # Need at most this many
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

B<rl_set> I<var> I<valur>

Sets an internal ReadLine variable like EditingMode or CompleteAddsuffix.

=head2 Examples:

   rl_set EditingMode emacs
   rl_set EditingMode vi

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    Term::ReadLine::Perl5::readline::rl_set($args[1], $args[2]);
}

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, 'EditingMode', 'emacs']);
    $cmd->run([$NAME, 'EditingMode', 'vi']);
}

1;
