# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use rlib '../../lib';
package Cmd::preinit;

use rlib '.';
use if !@ISA, Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 0;  # Need at least this many
use constant MAX_ARGS  => 0;  # Need at most this many - undef -> unlimited.
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

B<preinit>

Runs Term::ReadLine::Perl5's pre-initialize routine
=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    Term::ReadLine::Perl5::readline::preinit();
}

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
}

1;
