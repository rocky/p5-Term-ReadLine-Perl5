# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Cmd::rl_filename_list;
use Data::Printer;
use rlib '../../lib';
package Cmd::rl_filename_list;

use rlib '.';
use if !@ISA, Cmd;
unless (@ISA) {
    eval <<"EOE";
use constant MIN_ARGS  => 1;  # Need at least this many
use constant MAX_ARGS  => 1;  # Need at most this many
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

B<rl_filename_list> I<pattern>

Returns a list of files matching I<pattern>. Tilde expansion is not done
here.
=head2 See also:

C<tilde_expand>
=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my @args = @$args;
    my @matches =
	Term::ReadLine::Perl5::readline::rl_filename_list($args[1]);
    p @matches;
};

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME, substr(__FILE__, 0, 3)]);
    print '-' x 30, "\n";
    $cmd->run([$NAME, __FILE__]);
}

1;
