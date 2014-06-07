package Term::ReadLine::Perl5::Common;
use strict; use warnings;
use English;

=head1 NAME

Term::ReadLine::Perl5::Common

=head1 DESCRIPTION

A non-OO package which contains commmon routines for the OO (L<LTerm::ReadLine::Perl5::OO> and non-OO L<Term::ReadLine::Perl5::readline> routines of
L<Term::ReadLine::Common>

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

1;
