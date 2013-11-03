package Term::ReadLine::Perl5::History;
=pod

=head1 NAME

Term::ReadLine::Perl5::History

=head1 DESCRIPTION

Variables and functions supporting Term::ReadLine::Perl5's command
history.

=cut

use warnings;
use strict;

use vars qw(@EXPORT @ISA @rl_History $rl_HistoryIndex $rl_history_length
            $rl_MaxHistorySize $rl_max_input_history $history_stifled);

@ISA = qw(Exporter);
@EXPORT  = qw(@rl_History $rl_HistoryIndex $rl_history_length
              $rl_MaxHistorySize $rl_max_input_history $history_stifled);

@rl_History = ();
$rl_MaxHistorySize = 100;
$rl_history_length = 0;
$rl_max_input_history = 0;
$history_stifled = 0;

=head2 add_line_to_history

Insert C<$line> into history list if C<$line> is:

=over

=item *

bigger than the minimal length C<$minlength>

=item *

not same as last entry

=back

=cut

sub add_line_to_history
{
    my ($line, $minlength) = @_;
    if (length($line) >= $minlength
        && (!@rl_History || $rl_History[$#rl_History] ne $line)
       ) {
        ## if the history list is full, shift out an old one first....
        while (@rl_History >= $rl_MaxHistorySize) {
            shift(@rl_History);
            $rl_HistoryIndex--;
        }

        push(@rl_History, $line); ## tack new one on the end
    }
}


1;
