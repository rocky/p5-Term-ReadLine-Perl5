# -*- coding: utf-8 -*-
# Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
use strict; use warnings;
use Exporter;
use Array::Columnize;
use File::Basename;

package Cmd;

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

1;
