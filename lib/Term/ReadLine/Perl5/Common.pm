package Term::ReadLine::Perl5::Common;
use strict; use warnings;
use English;

=head1 NAME

Term::ReadLine::Perl5::Common

=head1 DESCRIPTION

A non-OO package which contains commmon routines for the OO (L<LTerm::ReadLine::Perl5::OO> and non-OO L<Term::ReadLine::Perl5::readline> routines of
L<Term::ReadLine::Common>

=cut

use Exporter;
use vars qw(@EXPORT @ISA);
@ISA     = qw(Exporter);
@EXPORT  = qw(ctrl unescape);

=head1 SUBROUTINES

=head2 KeyBinding functions

=head3 F_Ding

Ring the bell.

Should do something with I<$var_PreferVisibleBel> here, but what?
=cut

sub F_Ding($) {
    my $term_OUT = shift;
    local $\ = '';
    local $OUTPUT_RECORD_SEPARATOR = '';
    print $term_OUT "\007";
    return;    # Undefined return value
}

=head2 Internal function

=head3 ctrl

B<ctrl>(I<$ord>)

Returns the ordinal number for the corresponding control code.

For example I<ctrl(ord('a'))> returns the ordinal for I<Ctrl-A>
or 1. I<ctrl(ord('A'))> does the same thing.

=cut

sub ctrl {
    $_[0] ^ (($_[0]>=ord('a') && $_[0]<=ord('z')) ? 0x60 : 0x40);
}

=head2 _unescape

    _unescape($string) -> List of keys

This internal function that takes I<$string> possibly containing
escape sequences, and converts to a series of octal keys.

It has special rules for dealing with readline-specific escape-sequence
commands.

New-style key bindings are enclosed in double-quotes.
Characters are taken verbatim except the special cases:

    \C-x    Control x (for any x)
    \M-x    Meta x (for any x)
    \e      Escape
    \*      Set the keymap default   (JP: added this)
            (must be the last character of the sequence)
    \x      x  (unless it fits the above pattern)

Special case "\C-\M-x", should be treated like "\M-\C-x".

=cut

my @ESCAPE_REGEXPS = (
    # Ctrl-meta <x>
    [ qr/^\\C-\\M-(.)/, sub { ord("\e"), ctrl(ord(shift)) } ],
    # Meta <e>
    [ qr/^\\(M-|e)/, sub { ord("\e") } ],
    # Ctrl <x>
    [ qr/^\\C-(.)/, sub { ctrl(ord(shift)) } ],
    # hex value
    [ qr/^\\x([0-9a-fA-F]{2})/, sub { hex(shift) } ],
    # octal value
    [ qr/^\\([0-7]{3})/, sub { oct(shift) } ],
    # default
    [ qr/^\\\*$/, sub { 'default'; } ],
    # EOT (Ctrl-D)
    [ qr/^\\d/, sub { 4 } ],
    # Backspace
    [ qr/\\b/, sub { 0x7f } ],
    # Escape Sequence
    [ qr/\\(.)/,
      sub {
          my $chr = shift;
          ord(($chr =~ /^[afnrtv]$/) ? eval(qq("\\$chr")) : $chr);
      } ],
    );

sub unescape($) {
  my $key = shift;
  my @keys;

  CHAR: while (length($key) > 0) {
    foreach my $command (@ESCAPE_REGEXPS) {
      my $regex = $command->[0];
      if ($key =~ s/^$regex//) {
        push @keys, $command->[1]->($1);
        next CHAR;
      }
    }
    push @keys, ord($key);
    substr($key,0,1) = '';
  }
  @keys
}



1;
