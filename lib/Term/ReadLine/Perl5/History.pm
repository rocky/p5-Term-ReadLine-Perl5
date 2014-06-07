#  Copyright (C) 2014 Rocky Bernstein <rocky@cpan.org>
package Term::ReadLine::Perl5::History;
use rlib '.';
use Term::ReadLine::Perl5::OO::History;
=pod

=head1 NAME

Term::ReadLine::Perl5::History

=head1 DESCRIPTION

Variables and functions supporting L<Term::ReadLine::Perl5>'s command
history. This pretends to be OO code even though it doesn't make use
of the object's state. Instead it relies on a global history mechanism.

The underlying non-OO routines are elsewhere.

=cut

use warnings; use strict;

use vars qw(@EXPORT @ISA @rl_History $rl_HistoryIndex $rl_history_length
            $rl_MaxHistorySize $rl_max_input_history $history_base
            $history_stifled);

@ISA = qw(Exporter);
@EXPORT  = qw(@rl_History $rl_HistoryIndex $rl_history_length
              &add_line_to_history
              $rl_MaxHistorySize $rl_max_input_history $history_stifled);

# FIXME: eventually we will remove these variables when we are fully OO.
@rl_History = ();
$rl_MaxHistorySize = 100;
$rl_history_length = 0;
$rl_max_input_history = 0;
$rl_history_length = $rl_max_input_history = 0;

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

# Fake up a needed object using global state
sub _fake_self() {
    {
	rl_History => \@rl_History,
	rl_MaxHistorySize => $rl_MaxHistorySize,
	rl_HistoryIndex   => $rl_HistoryIndex,
	rl_history_length => $rl_history_length,
    };
}


# FIXME: DRY this adding a common routine to fake $self.
sub add_line_to_history($$)
{
    my ($line, $minlength) = @_;

    my $self = _fake_self();
    Term::ReadLine::Perl5::OO::History::add_line_to_history(
	$self, $line, $minlength);
}


sub add_history
{
    my $self = _fake_self();
    Term::ReadLine::Perl5::OO::History::add_history($self, @_);
    $rl_MaxHistorySize = $self->{rl_MaxHistorySize};
    $rl_HistoryIndex   = $self->{rl_HistoryIndex};
}


sub remove_history($)
{
    my ($which) = @_;
    my $self = _fake_self();
    Term::ReadLine::Perl5::OO::History::remove_history($self, $which);
    @rl_History = @{$self->{rl_History}};
    $rl_MaxHistorySize = $self->{rl_MaxHistorySize};
    $rl_HistoryIndex   = $self->{rl_HistoryIndex};
    $rl_history_length = $self->{rl_history_length};
}

sub clear_history()
{
    my $self = _fake_self();
    Term::ReadLine::Perl5::OO::History::clear_history($self);
    @rl_History = @{$self->{rl_History}};
    $rl_MaxHistorySize = $self->{rl_MaxHistorySize};
    $rl_HistoryIndex   = $self->{rl_HistoryIndex};
    $rl_history_length = $self->{rl_history_length};
}

sub GetHistory()
{
    Term::ReadLine::Perl5::OO::History::GetHistory(_fake_self());
}


sub SetHistory
{
    # Fake up a needed object using global state

    my $self = _fake_self();
    Term::ReadLine::Perl5::OO::History::SetHistory($self, @_);
    @rl_History = @{$self->{rl_History}};
    $rl_MaxHistorySize = $self->{rl_MaxHistorySize};
    $rl_HistoryIndex   = $self->{rl_HistoryIndex};
    $rl_history_length = $self->{rl_history_length};
}


1;
