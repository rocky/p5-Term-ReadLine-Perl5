# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use Array::Columnize;
use Pod::Text;
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

B<help> [I<command|regular-expression> | *]

=head2 Examples:

    help help  # Run help on the help command (this output)
    help       # Give basic help instructions
    help *     # Give a list of commands
    help re.*  # list all comands that start re

=cut
HELP

sub command_names($)
{
    my ($self) = @_;
    my $proc = $self->{proc};
    my %cmd_hash = %{$proc->{commands}};
    my @commands = keys %cmd_hash;
    return @commands;
}

sub help2podstring($)
{
    my ($input_string) = @_;
    my $width = ($ENV{'COLUMNS'} || 80);

    my $p2t = Pod::Text->new(width => $width, indent => 2, utf8=>1);
    my $output_string;
    open(my $out_fh, '>', \$output_string);
    open(my $in_fh, '<', \$input_string);

    $input_string = "=pod\n\n$input_string" unless
        "=pod\n" eq substr($input_string, 0, 4);
    $input_string .= "\n=cut\n" unless
        "\n=cut\n" eq substr($input_string, -6);
    $p2t->parse_from_file($in_fh, $out_fh);
    return $output_string;
}

sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $cmd_name = $args->[1];
    if (scalar(@$args) > 1) {
        my $real_name;
        if ($cmd_name eq '*') {
            print "All currently valid command names:\n";
            my @cmds = sort($self->command_names());
	    print Array::Columnize::columnize(\@cmds,
					      {displaywidth => $proc->{num_cols},
					       colsep => '  ',
					      });
        } else {
            my $cmd_obj = $proc->{commands}{$cmd_name};
	    if ($cmd_obj) {
		my $help_text =
		    $cmd_obj->can('help') ? $cmd_obj->help($args)
		    : $cmd_obj->{help};
		if ($help_text) {
		    $help_text = help2podstring($help_text);
		    chomp $help_text; chomp $help_text;
		    print $help_text, "\n";
		}
	    } else {
		my @cmds = $self->command_names();
		my @matches = sort grep(/^${cmd_name}/, @cmds );
		if (!scalar @matches) {
		    print "No commands found matching /^${cmd_name}/. Try \"help\".\n";
		} else {
		    print "Command names matching /^${cmd_name}/:\n";
		    print Array::Columnize::columnize(\@matches,
						      {displaywidth => $proc->{num_cols},
						       colsep => '  ',
						      });
		}
	    }
        }
    } else {
        print "Enter help * for a list of commands\n";
	print "or help <command> for help on a particular command.\n";
    }
}

unless (caller) {
    require CmdProc;
    my $proc = CmdProc->new;
    $proc->{num_cols} = 30;
    my $cmd = __PACKAGE__->new($proc);
    $cmd->run([$NAME]);
    print '-' x 30, "\n";
    $cmd->run([$NAME, '*']);
    print '-' x 30, "\n";
    $cmd->run([$NAME, 'help']);
}

1;
