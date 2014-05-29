# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use rlib '../../lib';
package Cmd::rl_bind;

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

B<rl_bind> I<$keyspec> I<$function>

Maps  I<$keyspec>, $function in the current KeyMap.

=head2 Examples:

   rl_bind \e[[A  previous-history
   rl_bind \e[[C  forward-char

=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    Term::ReadLine::Perl5::readline::rl_bind($args[1], $args[2]);
}

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, '\e[[A', 'previous-history']);
    $cmd->run([$NAME, '\e[[C', 'forward-char']);
}

1;
