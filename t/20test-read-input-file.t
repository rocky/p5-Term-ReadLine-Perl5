#!/usr/bin/env perl

# About the numbering 20.. This should probably go after the
# unescape test since read_an_input_file() calls unescape(). So if the
# unescape fails, we probably expect this one to as well.

# Lots of boilerplate here... Put in a helper file?
use strict; use warnings;
use rlib '.'; use Helper;

note("read_an_init_file");

my $dir = File::Spec->catfile(dirname(__FILE__));
$dir = File::Spec->rel2abs( $dir ) unless
    File::Spec->file_name_is_absolute( $dir );

$dir = File::Spec->rel2abs( $dir ) unless
    File::Spec->file_name_is_absolute( $dir );

my $input_file = File::Spec->catfile($dir, qw(data undo.inputrc));
readline::read_an_init_file($input_file);

# use Data::Printer;
# p @{readline::emacs_keymap};

# Some tests! (Just when you thought we'd never get around to it.)
for my $i (1..8) {
    no warnings 'once';
    is($readline::emacs_keymap[$i], 'F_Undo', "emacs_keymap[$i] reassigned")
}

done_testing();
