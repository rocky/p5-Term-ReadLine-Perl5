# -*- Perl -*-
package Term::ReadLine::Perl5;

=encoding utf8

=head1 NAME

Term::ReadLine::Perl5 - A Perl5 implementation GNU Readline

=head2 Overview

This is a implementation of the GNU Readline/History Library written
in Perl5.

GNU Readline reads lines from an interactive terminal with I<emacs> or
I<vi> editing capabilities. It provides as mechanism for saving
history of previous input.

This package typically used in command-line interfaces and REPLs (Read,
Eval, Print, Loop).

=head1 SYNOPSIS

  use Term::ReadLine::Perl5;
  $term = new Term::ReadLine::Perl5 'ProgramName';
  while ( defined ($_ = $term->readline('prompt>')) ) {
    ...
  }

=cut

use warnings; use strict;
no warnings 'once';

our $VERSION = '1.37';

use Carp;
use Term::ReadLine::Perl5::History;
use Term::ReadLine::Perl5::Tie;
use Term::ReadLine::Perl5::readline;

our @ISA = qw(Term::ReadLine::Stub);
my (%attribs, $term);

=head2 Variables

Following GNU Readline/History Library variables can be accessed from
Perl program.  See 'GNU Readline Library Manual' and ' GNU History
Library Manual' for each variable.  You can access them via the
C<Attribs> method.  Names of keys in this hash conform to standard
conventions with the leading C<rl_> stripped.

Example:

    $term = new Term::ReadLine::Perl5 'ReadLineTest'
    $attribs = $term->Attribs;
    $v = $attribs->{history_base};	# history_base

=head3 Attribute Names

	completion_suppress_append (bool)
	history_base               (int)
	history_stifled            (int)
        history_length             (int)
        max_input_history          (int)
	outstream                  (file handle)

=cut

my %features = (
		 appname => 1,       # "new" is recognized
		 minline => 1,       # we have a working MinLine()
		 autohistory => 1,   # lines are put into history automatically,
		                     # subject to MinLine()
		 getHistory => 1,    # we have a working getHistory()
		 setHistory => 1,    # we have a working setHistory()
		 addHistory => 1,    # we have a working add_history(), addhistory(),
                                     # or addHistory()
		 readHistory => 1,   # we have read_history() or readHistory()
		 writeHistory => 1,  # we have writeHistory()
		 preput => 1,        # the second argument to readline is processed
		 attribs => 1,
		 newTTY => 1,        # we have newTTY()
		 stiflehistory => 1, # we have stifle_history()
      );

sub Features { \%features; }

tie %attribs, 'Term::ReadLine::Perl5::Tie' or die ;
sub Attribs {
  \%attribs;
}

=head2 SUBROUTINES

=cut

sub readline {
  shift;
  &Term::ReadLine::Perl5::readline::readline(@_);
}

=head3 new

C<Term::ReadLine::Perl-E<gt>new($name, [*IN, [*OUT])>

Returns a handle for subsequent calls to readline functions.

C<$name> is the name of the application.

Optionally you can add two arguments for input and output
filehandles. These arguments should be globs.

This routine might also be called via
C<Term::ReadLine-E<gt>new($term_name)> if other Term::ReadLine packages
like L<Term::ReadLine::Gnu> is not available or if you have
C<$ENV{PERL_RL}> set to 'Perl5';

I<Note>: Some additional feature via Term::ReadLine::Stub are added
when a "new" is done

At present, because this code has lots of global state, we currently don't
support more than one readline instance.

Somebody please volunteer to rewrite this code!

=cut
sub new {
  require Term::ReadLine;
  $features{tkRunning} = Term::ReadLine::Stub->Features->{'tkRunning'};
  $features{ornaments} = Term::ReadLine::Stub->Features->{'ornaments'};
  if (defined $term) {
    warn "Cannot create second readline interface, falling back to dumb.\n";
    return Term::ReadLine::Stub::new(@_);
  }
  shift; # Package name
  if (@_) {
    if ($term) {
      warn "Ignoring name of second readline interface.\n" if defined $term;
      shift;
    } else {
      $Term::ReadLine::Perl5::readline::rl_readline_name = shift; # Name
    }
  }
  if (!@_) {
    if (!defined $term) {
      my ($IN,$OUT) = Term::ReadLine->findConsole();
      # Old Term::ReadLine did not have a workaround for a bug in Win devdriver
      $IN = 'CONIN$' if $^O eq 'MSWin32' and "\U$IN" eq 'CON';
      open IN,
	# A workaround for another bug in Win device driver
	(($IN eq 'CONIN$' and $^O eq 'MSWin32') ? "+< $IN" : "< $IN")
	  or croak "Cannot open $IN for read";
      open(OUT,">$OUT") || croak "Cannot open $OUT for write";
      $Term::ReadLine::Perl5::readline::term_IN = \*IN;
      $Term::ReadLine::Perl5::readline::term_OUT = \*OUT;
    }
  } else {
    if (defined $term and ($term->IN ne $_[0] or $term->OUT ne $_[1]) ) {
      croak "Request for a second readline interface with different terminal";
    }
    $Term::ReadLine::Perl5::readline::term_IN = shift;
    $Term::ReadLine::readline::term_OUT = shift
  }
  eval {require Term::ReadLine::Perl5::readline}; die $@ if $@;
  # The following is here since it is mostly used for perl input:
  # $readline::rl_basic_word_break_characters .= '-:+/*,[])}';
  $term = bless [$readline::term_IN,$readline::term_OUT];
  unless ($ENV{PERL_RL} and $ENV{PERL_RL} =~ /\bo\w*=0/) {
    local $Term::ReadLine::termcap_nowarn = 1; # With newer Perls
    local $SIG{__WARN__} = sub {}; # With older Perls
    $term->ornaments(1);
  }
  $rl_history_length = $rl_max_input_history = 0;
  return $term;
}

sub newTTY {
  my ($self, $in, $out) = @_;
  $Term::ReadLine::Perl5::readline::term_IN   = $self->[0] = $in;
  $Term::ReadLine::Perl5::readline::term_OUT  = $self->[1] = $out;
  my $sel = select($out);
  $| = 1;				# for DB::OUT
  select($sel);
}

sub ReadLine {'Term::ReadLine::Perl5'}

=head3 Minline

C<MinLine([$minlength])>

If C<$minlength> is given, set C<$readline::minlength> the minimum
length a $line for it to go into the readline history.

The previous value is returned.
=cut
sub MinLine($;$) {
    my $old = $minlength;
    $minlength = $_[1] if @_ == 2;
    return $old;
}

=head2 History Subroutines

=cut
#################### History ##########################################

# GNU ReadLine names
*add_history            = \&Term::ReadLine::Perl5::History::add_history;
*clear_history          = \&Term::ReadLine::Perl5::History::clear_history;
*history_list           = \&Term::ReadLine::Perl5::History::history_list;
*history_is_stifled     = \&Term::ReadLine::Perl5::History::history_is_stifled;
*read_history           = \&Term::ReadLine::Perl5::History::read_history;
*replace_history_entry  = \&Term::ReadLine::Perl5::History::replace_history_entry;
*unstifle_history       = \&Term::ReadLine::Perl5::History::unstifle_history;
*write_history          = \&Term::ReadLine::Perl5::History::write_history;

# Some Term::ReadLine::Gnu names
*AddHistory             = \&Term::ReadLine::Perl5::History::AddHistory;
*GetHistory             = \&Term::ReadLine::Perl5::History::GetHistory;
*ReadHistory            = \&Term::ReadLine::Perl5::History::ReadHistory;
*SetHistory             = \&Term::ReadLine::Perl5::History::SetHistory;
*WriteHistory           = \&Term::ReadLine::Perl5::History::WriteHistory;

# Backward compatibility:
*addhistory = \&Term::ReadLine::Perl5::add_history;
*StifleHistory = \&stifle_history;

=head3 stifle_history

C<stifle_history($max)>

Stifle or put a cap on the history list, remembering only C<$max>
number of lines.

=cut
### FIXME: stifle_history is still here because it updates $attribs.
## Pass a reference?
sub stifle_history($$) {
  shift;
  my $max = shift;
  $max = 0 if !defined($max) || $max < 0;

  if (scalar @rl_History > $max) {
      splice @rl_History, $max;
      $attribs{history_length} = scalar @rl_History;
  }

  $history_stifled = 1;
  $rl_max_input_history = $max;
}

=head3 remove_history

C<remove_history($which)>

Remove history element C<$which> from the history. The removed
element is returned.
=cut

sub remove_history($$) {
  shift;
  my $which = $_[0];
  return undef if
    $which < 0 || $which >= $rl_history_length ||
      $attribs{history_length} ==  0;
  my $removed = splice @rl_History, $which, 1;
  $rl_history_length--;
  $rl_HistoryIndex =
      $rl_history_length if
    $rl_history_length <
    $rl_HistoryIndex;
  return $removed;
}

1;
