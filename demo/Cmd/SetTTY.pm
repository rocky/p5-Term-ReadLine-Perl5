# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Cmd::SetTTY;
use rlib '../../lib';

use rlib '.';
use if !@ISA, Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 0;  # Need at least this many
use constant MAX_ARGS  => 0;  # Need at most this many
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

B<SetTTY>

Sets TTY state.

=head2 See also:

C<ResetTTY>
=cut
HELP

sub run($$) {
    Term::ReadLine::Perl5::readline::SetTTY();
}

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
}

1;
