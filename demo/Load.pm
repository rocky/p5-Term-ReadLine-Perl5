# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>

# Part of demo that loads up debugger commands from
# builtin and user directories.
# Sets @commands, @aliases, @macros
use rlib '../../..';

package CmdProc;
$Load_seen = 1;
use warnings; use strict;
no warnings 'redefine';

use File::Spec;
use File::Basename;
use Cwd 'abs_path';

=head2 load_cmds_initialize

  load_debugger_commands($self) -> undef

Loads in our built-in commands.

Called from Devel::Trepan::CmdProcessor->new in CmdProcessor.pm
=cut

sub load_cmds_initialize($)
{
    my $self = shift;
    $self->{commands} = {};

    my @cmd_dirs = (
        File::Spec->catfile(dirname(__FILE__), 'Cmd'));
    for my $cmd_dir (@cmd_dirs) {
        $self->load_debugger_commands($cmd_dir) if -d $cmd_dir;
    }
}

=head2 load_debugger_commands

  load_debugger_commands($self, $file_or_dir) -> @errors

Loads in debugger commands by require'ing each Perl file in the
'command' directory. Then a new instance of each class of the
form Trepan::xxCommand is added to @commands and that array
is returned.
=cut
sub load_debugger_commands($$)
{
    my ($self, $file_or_dir) = @_;
    my @errors = ();
    if ( -d $file_or_dir ) {
        my $dir = abs_path($file_or_dir);
        # change $0 so it doesn't get in the way of __FILE__ eq $0
        # old_dollar0 = $0
        # $0 = ''
        for my $pm (glob(File::Spec->catfile($dir, '*.pm'))) {
            my $err = $self->load_debugger_command($pm);
	    push @errors, $err if $err;
        }
        # $0 = old_dollar0
    } elsif (-r $file_or_dir) {
        my $err = $self->load_debugger_command($file_or_dir);
	push @errors, $err if $err;
    }
    return @errors;
  }

=head2 load_debugger_command

  load_debugger_command($self, $command_file, [$force])

Loads a debugger command. Returns a string containing the error or '' if no error.
=cut

sub load_debugger_command($$;$)
{
    my ($self, $command_file, $force) = @_;
    return unless -r $command_file;
    my $rc = '';
    eval { $rc = do $command_file; };
    if (!$rc or $rc eq 'Skip me!') {
        return 'skipped';
    } elsif ($rc) {
        # Instantiate each Command class found by the above require(s).
        my $name = basename($command_file, '.pm');
        return $self->setup_command($name);
    } else {
	my $errmsg = "Trouble reading ${command_file}: $@";
        print $errmsg, "\n";
	return $errmsg;
    }
}

=head2 run_cmd

  run_cmd($self, $cmd_arry)

Looks up cmd_array[0] in @commands and runs that. We do lots of
validity testing on cmd_array.

=cut
sub run_cmd($$)
{
    my ($self, $cmd_array) = @_;
    unless ('ARRAY' eq ref $cmd_array) {
        my $ref_msg = ref($cmd_array) ? ", got: " . ref($cmd_array): '';
        print "run_cmd argument should be an Array reference$ref_msg\n";
        return;
    }
    # if ($cmd_array.detect{|item| !item.is_a?(String)}) {
    #   $self ->errmsg("run_cmd argument Array should only contain strings. " .
    #                  "Got #{cmd_array.inspect}");
    #   return;
    # }
    if (0 == scalar @$cmd_array) {
        print "run_cmd Array should have at least one item\n";
        return;
    }
    my $cmd_name = $cmd_array->[0];
    if (exists($self->{commands}{$cmd_name})) {
        $self->{commands}{$cmd_name}->run($cmd_array);
    }
}

=head2 setup_command

  setup_command($self, $name)

Instantiate a Cmd and extract info: the NAME
and store the command in @commands.
=cut
sub setup_command($$)
{
    my ($self, $name) = @_;
    my $cmd_obj;
    my $cmd_name = $name;
    my $new_cmd = "\$cmd_obj=Cmd::${name}" .
        "->new(\$self, \$cmd_name); 1";
    if (eval $new_cmd) {
        # Add to list of commands
        $self->{commands}{$cmd_name} = $cmd_obj;
	return '';
    } else {
        print "Error instantiating $name\n";
	return $@;
    }
  }

unless (caller) {
    require CmdProc;
    my $cmdproc = CmdProc->new;
    $cmdproc->load_cmds_initialize();
    $cmdproc->{num_cols} = 30;
    require Array::Columnize;
    my @cmds = sort keys(%{$cmdproc->{commands}});
    print Array::Columnize::columnize(\@cmds);
    my $sep = '=' x 20 . "\n";
    print $sep;

    $cmdproc->run_cmd('foo');  # Invalid - not an Array
    $cmdproc->run_cmd([]);     # Invalid - empty Array
    $cmdproc->run_cmd(['help', '*']);
    # $cmdproc->run_cmd(['list', 5]);  # Invalid - nonstring arg
}

1;
