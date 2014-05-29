# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Data::Printer;
use rlib '../../lib';
package Cmd::rl_read_init_file;

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

B<rl_read_init_file> I<filename>

Read key bindings and variable assignments from filename.

Runs L<Term::ReadLine::Perl5::read_init_file>.
=cut
HELP

sub run($$) {
    my ($self, $args) = @_;
    my $filename = $args->[1];

    if (Term::ReadLine::Perl5::readline::rl_read_init_file($filename)) {
	print "Filename $filename read\n";
    } else {
	print "Problem reading $filename\n";
    };
}

unless (caller) {
    my $proc = Cmd->new;
    my $cmd = __PACKAGE__->new($proc);
    # $cmd->run([$NAME, '~/.initrc');
}

1;
