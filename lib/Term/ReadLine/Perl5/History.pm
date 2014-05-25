#  Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Term::ReadLine::Perl5::History;
=pod

=head1 NAME

Term::ReadLine::Perl5::History

=head1 DESCRIPTION

Variables and functions supporting L<Term::ReadLine::Perl5>'s command
history. This pretends to be OO code even though it doesn't make use
of the object's state. Instead it relies on a global history mechanism.

The underlying non-OO routines are elsewhere.

=cut

use warnings;
use strict;

use vars qw(@EXPORT @ISA @rl_History $rl_HistoryIndex $rl_history_length
            $rl_MaxHistorySize $rl_max_input_history $history_base
            $history_stifled);

@ISA = qw(Exporter);
@EXPORT  = qw(@rl_History $rl_HistoryIndex $rl_history_length
              &add_line_to_history
              $rl_MaxHistorySize $rl_max_input_history $history_stifled);

@rl_History = ();
$rl_MaxHistorySize = 100;
$rl_history_length = 0;
$rl_max_input_history = 0;

$history_stifled = 0;
$history_base    = 0;

=head1 SUBROUTINES

=head2 add_line_to_history

B<add_line_to_history>(I<$line>, I<$minlength>)

Insert I<$line> into history list if I<$line> is:

=over

=item *

bigger than the minimal length I<$minlength>

=item *

not same as last entry

=back

=cut

sub add_line_to_history($$)
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


=head2 add_history

B<add_history>(I<$line1>, ...)

Place lines in array I<@_> at the end of the history list unless the
history is stifled, or there are already too many items.

=cut

sub add_history($) {
    shift;
    if ($history_stifled &&
	($rl_history_length ==
	 $rl_max_input_history)) {
	# If the history is stifled, and history_length is zero,
	# and it equals max_input_history, we don't save items.
	return if $rl_max_input_history == 0;
	shift @rl_History;
    }

    push @rl_History, @_;
    $rl_HistoryIndex =
	@rl_History + @_;
    $rl_history_length =
	scalar @rl_History;
}

=head2 clear_history

B<clear_history>()

Clear or reset readline history.

=cut

sub clear_history($) {
  shift;
  @rl_History = ();
  $rl_HistoryIndex =
      $rl_history_length = 0;
}

sub history_list($)
{
    @rl_History[1..$#rl_History]
}

=head2 replace_history_entry

B<replace_history_entry(I<$which>, I<$data>)>

Make the history entry at I<$which> have I<$data>.  This returns the old
entry. In the case of an invalid I<$which>, I<undef> is returned.

=cut

sub replace_history_entry($) {
  shift;
  my ($which, $data) = @_;
  return undef if $which < 0 || $which >= $rl_history_length;
  my $replaced = splice @rl_History, $which, 1, $data;
  return $replaced;
}

=head2 unstifle_history

C<unstifle_history>

Unstifle or remove limit the history list.

Theprevious maximum number of history entries is returned.  The value
is positive if the history was stifled and negative if it wasn't.

=cut

sub unstifle_history($) {
    if ($history_stifled) {
	$history_stifled = 0;
	return (scalar @rl_History);
    } else {
	return - scalar @rl_History;
    }
}

=head2 history_is_stifled

C<history_is_stifled>

Returns I<true> if saved history has a limited (stifled) or I<false>
if there is no limit (unstifled).

=cut

sub history_is_stifled {
  shift;
  $history_stifled ? 1 : 0;
}

# read_history() and write_history() follow GNU Readline's
# C convention of returning 0 for success and 1 for failure.
#
# ReadHistory and WriteHstory follow Perl's convention of returning 1
# for success and 0 for failure.
# It is a little bit whacky, but this is in fact how Term::ReadLine::Gnu
# works.

sub read_history {
    my @history;
    my $self = shift;
    my $filename = shift;
    open(HISTORY, '<', $filename ) or return 1;
    while (<HISTORY>) { chomp; push @history, $_} ;
    SetHistory($self, @history);
    close HISTORY;
    return 0;
}

=head2 remove_history

B<remove_history>(I<$which>, I<$history_length>)

Remove history element C<$which> from the history. The removed
element is returned.

=cut

sub remove_history {
    my ($which, $history_length) = @_;
    return undef if
	$which < 0 || $which >= $rl_history_length ||
	$history_length ==  0;
    my $removed = splice @rl_History, $which, 1;
    $rl_history_length--;
    $rl_HistoryIndex =
	$rl_history_length if
	$rl_history_length <
	$rl_HistoryIndex;
    return $removed;
}

sub write_history {
    shift;
    my $filename = shift;
    open(HISTORY, '>', $filename ) or return 1;
    for (@rl_History) { print HISTORY $_, "\n"; }
    close HISTORY;
    return 0;
}

=head2 ReadHistory

B<ReadHistory>([I<$filename> [,I<$from> [,I<$to>]]])

	$i = read_history('~/.history')
	$i = read_history_range('~/.history')

Adds the contents of I<$filename> to the history list, a line at a
time.  If $<filename> is false, then read from F<~/.history>.  Start
reading at line I<$from> and end at I<$to>.  If I<$from> is omitted or
zero, start at the beginning.  If I<$to> is omitted or less than
I<$from>, then read until the end of the file.  Returns true if
successful, or false if not.

I<read_history()> is an alias of I<read_history_range()>.

=cut

sub ReadHistory {
    ! read_history(@_);
}

=head2 WriteHistory

B<WriteHistory>([I<$filename>])

	$i = write_history('~/.history')

Writes the current history to I<$filename>, overwriting I<$filename> if
necessary.  If I<$filename> is false, then write the history list to
F<~/.history>.  Returns true if successful, or false if not.


=cut

sub WriteHistory {
    ! write_history(@_);
}

=head2 SetHistory

B<SetHistory>(I<$line1> [, I<$line2>, ...])

Sets the history of input, from where it can be used.

=cut

sub SetHistory {
    shift;
    @rl_History = @_;
    $rl_HistoryIndex = @rl_History;
    $rl_history_length = $rl_max_input_history = scalar(@rl_History);
}

=head2 GetHistory

B<GetHistory>

returns the history of input as a list.

=cut

sub GetHistory {
    @rl_History;
}

=head1 AUTHOR

Rocky Bernstein

=head1 SEE ALSO

L<Term::ReadLine::Perl5>

=cut
1;
