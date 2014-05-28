# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use strict; use warnings;
use Exporter;
use Array::Columnize;
use File::Basename;

package Cmd;
use Data::Printer;

use vars qw(@CMD_VARS @EXPORT @ISA @CMD_ISA $HELP %commands @commands);
BEGIN {
    @CMD_VARS = qw($HELP $NAME @CMD_VARS);
}
use vars @CMD_VARS;
@ISA = qw(Exporter);

@CMD_ISA  = qw(Cmd);
@EXPORT = qw(&set_name @CMD_ISA @CMD_VARS declared %commands @commands);

use rlib '../lib';
use Term::ReadLine::Perl5;
use rlib '.';
use Load;

# # Because we use Exporter we want to silence:
# #   Use of inherited AUTOLOAD for non-method ... is deprecated
# sub AUTOLOAD
# {
#     my $name = our $AUTOLOAD;
#     $name =~ s/.*:://;  # lose package name
#     my $target = "DynaLoader::$name";
#     goto &$target;
# }

# sub DESTROY {}

my ($num_cols,$num_rows) =  Term::ReadKey::GetTerminalSize(\*STDOUT);

sub set_name() {
    my ($pkg, $file, $line) = caller;
    lc(File::Basename::basename($file, '.pm'));
}

sub new($$) {
    my($class, $proc)  = @_;
    my $self = {
        proc     => $proc,
	num_cols => $num_cols,
        class    => $class,
    };
    my $base_prefix="Cmd::";
    for my $field (@CMD_VARS) {
        my $sigil = substr($field, 0, 1);
        my $new_field = index('$@', $sigil) >= 0 ? substr($field, 1) : $field;
        if ($sigil eq '$') {
            $self->{lc $new_field} =
                eval "\$${class}::${new_field} || \$${base_prefix}${new_field}";
        } elsif ($sigil eq '@') {
            $self->{lc $new_field} = eval "[\@${class}::${new_field}]";
        } else {
            die "Woah - bad sigil in variable $field: $sigil ";
        }
    }
    no warnings;
    no strict 'refs';
    *{"${class}::name"} = eval "sub { \$${class}::NAME }";
    bless $self, $class;
    $self;
}

############### The reset will be removed.... ####################
sub print_features($) {
    my $term = shift;
    my @features = sort keys %{ $term->Features; };
    print "Features:\n";
    print Array::Columnize::columnize(\@features,
				      {displaywidth => $num_cols,
				       colsep => ' ',
				       lineprefix => '  '});
}

sub cmd_ResetTTY {
    Term::ReadLine::Perl5::readline::ResetTTY();
};

sub cmd_SetTTY {
    Term::ReadLine::Perl5::readline::SetTTY();
};

sub cmd_exit {
};

sub cmd_help {
    print "Commands:\n";
    print Array::Columnize::columnize(\@commands,
				      {displaywidth => $num_cols,
				       colsep => '  ',
				      });
};

sub cmd_init {
    Term::ReadLine::Perl5::readline::init();
};
sub cmd_preinit {
    print "preinit called!\n";
    Term::ReadLine::Perl5::readline::preinit();
};

sub cmd_read_an_init_file {
    my @args = @_;
    my $filename = $args[1];
    my $result =
	Term::ReadLine::Perl5::readline::read_an_init_file($filename);
    if ($result) {
	print "File $filename read ok\n";
    } else {
	print "File $filename did not read ok\n";
    }
};

sub cmd_redisplay {
    Term::ReadLine::Perl5::readline::redisplay();
};

sub cmd_rl_filename_list {
    my @args = @_;
    my @matches =
	Term::ReadLine::Perl5::readline::rl_filename_list($args[1]);
    p @matches;
};

sub cmd_rl_set {
    my @args = @_;
    if (@args != 3) {
	printf "Was expecting exactly two args, got %d\n", $#args;
    } else  {
	Term::ReadLine::Perl5::readline::rl_set($args[1], $args[2]);
    }
};
sub cmd_tilde_complete {
    my @args = @_;
    my $prefix = (@args == 1) ? '~': $args[1];
    if (substr($prefix, 0, 1) ne '~') {
	print "Tilde expansion expected to start with ~\n";
    } else {
	$prefix = substr($prefix, 1);
	my @matches =
	    Term::ReadLine::Perl5::readline::tilde_complete($prefix);
	p @matches;
    }
};

1;
