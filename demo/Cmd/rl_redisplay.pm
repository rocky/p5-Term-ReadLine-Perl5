# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Cmd::rl_redisplay;
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

B<redisplay>

Runs L<Term::ReadLine::Perl5::readline::rl_redisplay> which
Updates the screen to reflect the current value of the line.

=cut
HELP

sub run($$) {
    Term::ReadLine::Perl5::readline::redisplay();
}

unless (caller) {
    my $proc = Cmd->new;
    # require Term::ReadLine::Perl5;
    # my $term = new Term::ReadLine::Perl5 'Feature test';
    # $proc->{term} = $term;
    # my $cmd = __PACKAGE__->new($proc);
    # $cmd->run([$NAME]);
}

1;
