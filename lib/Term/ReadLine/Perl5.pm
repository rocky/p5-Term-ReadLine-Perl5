# -*- Perl -*-
package Term::ReadLine::Perl5;

use Term::ReadLine;  # Needed for Term::ReadLine::Stub

=head1 NAME

Term::ReadLine::Perl5 - A pure Perl implementation GNU Readline

=head1 SYNOPSIS

  use Term::ReadLine::Perl5;
  $term = new Term::ReadLine::Perl5 'ProgramName';
  while ( defined ($_ = $term->readline('prompt>')) ) {
    ...
  }

=head1 DESCRIPTION

=head2 Overview

This is a implementation of the GNU Readline/History Library written
entirely in Perl.

GNU Readline reads lines from an interactive terminal with I<emacs> or
I<vi> editing capabilities. It provides as mechanism for saving
history of previous input.

This package typically used in command-line interfaces and REPLs (Read,
Eval, Print Loops).

=cut


use Carp;
@ISA = qw(Term::ReadLine::Stub Term::ReadLine::Perl5::AU);
#require 'readline.pl';

$VERSION = 1.04;

=head2 SUBROUTINES

=cut 

sub readline {
  shift; 
  &readline::readline(@_);
}

# add_history is what GNU ReadLine defines. AddHistory is what we have
# below.
*add_history = \&AddHistory;

# Not sure if addhistory() is needed. It is possible it was misspelling
# of add_history. 
*addhistory = \&AddHistory; 

# for backward compatibility: StifleHistory is the old name.
*StifleHistory = \&stifle_history;

# Initializations of variables to pacify -w
$readline::minlength = 1;
$readline::rl_readline_name = undef;
$readline::rl_basic_word_break_characters = undef;
$readline::history_stifled = 0;
$readline::rl_history_length = 0;
$readline::rl_max_input_history = 0;


=head2

C<Term::ReadLine::Perl->new($name, [*IN, [*OUT])>

Returns a handle for subsequent calls to readline functions. 

C<$name> is the name of the application. 

Optionally you can add two arguments for input and output
filehandles. These arguments should be globs.

This routine might also be called via
C<Term::ReadLine->new($term_name)> if other Term::ReadLine packages
like L<Term::ReadLine::Gnu> is not available or if you have
C<$ENV{PERL_RL}> set to 'Perl';

At present, because this code has lots of global state, we currently don't
support more than one readline instance. 

Somebody please volunteer to rewrite this code!

=cut

sub new {
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
      $readline::rl_readline_name = shift; # Name
    }
  }
  if (!@_) {
    if (!defined $term) {
      ($IN,$OUT) = Term::ReadLine->findConsole();
      # Old Term::ReadLine did not have a workaround for a bug in Win devdriver
      $IN = 'CONIN$' if $^O eq 'MSWin32' and "\U$IN" eq 'CON';
      open IN,
	# A workaround for another bug in Win device driver
	(($IN eq 'CONIN$' and $^O eq 'MSWin32') ? "+< $IN" : "< $IN")
	  or croak "Cannot open $IN for read";
      open(OUT,">$OUT") || croak "Cannot open $OUT for write";
      $readline::term_IN = \*IN;
      $readline::term_OUT = \*OUT;
    }
  } else {
    if (defined $term and ($term->IN ne $_[0] or $term->OUT ne $_[1]) ) {
      croak "Request for a second readline interface with different terminal";
    }
    $readline::term_IN = shift;
    $readline::term_OUT = shift
  }
  eval {require Term::ReadLine::readline}; die $@ if $@;
  # The following is here since it is mostly used for perl input:
  # $readline::rl_basic_word_break_characters .= '-:+/*,[])}';
  $term = bless [$readline::term_IN,$readline::term_OUT];
  unless ($ENV{PERL_RL} and $ENV{PERL_RL} =~ /\bo\w*=0/) {
    local $Term::ReadLine::termcap_nowarn = 1; # With newer Perls
    local $SIG{__WARN__} = sub {}; # With older Perls
    $term->ornaments(1);
  }
  $readline::rl_history_length = $readline::rl_max_input_history = 0;
  return $term;
}

sub newTTY {
  my ($self, $in, $out) = @_;
  $readline::term_IN   = $self->[0] = $in;
  $readline::term_OUT  = $self->[1] = $out;
  my $sel = select($out);
  $| = 1;				# for DB::OUT
  select($sel);
}

sub ReadLine {'Term::ReadLine::Perl5'}

=head2

C<MinLine([$minlength])>

If C<$minlength> is given, set C<$readline::minlength> the minimum
length a $line for it to go into the readline history.

The previous value is returned.

=cut

sub MinLine {
    my $old = $readline::minlength;
    $readline::minlength = $_[1] if @_ == 2;
    return $old;
}

sub SetHistory {
    shift;
    @readline::rl_History = @_;
    $readline::rl_HistoryIndex = @readline::rl_History;
    $readline::rl_history_length = $readline::rl_max_input_history =
	@readline::rl_History;
}

sub GetHistory {
    @readline::rl_History;
}

=head2 AddHistory

C<AddHistory($line1, ...)>

Place @_ at the end of the history list unless the history is stifled,
or there are already too many items.

=cut

sub AddHistory {
    shift;
    if ($readline::history_stifled &&
	($readline::rl_history_length == $readline::rl_max_input_history)) {
	# If the history is stifled, and history_length is zero,
	# and it equals max_input_history, we don't save items.
	return if $readline::rl_max_input_history == 0;
	shift @readline::rl_History;
    }

    push @readline::rl_History, @_;
    $readline::rl_HistoryIndex = @readline::rl_History + @_;
    $readline::rl_history_length = scalar @readline::rl_History;
}

=head2 clear_history

C<clear_history()>

Clear or reset readline history.

=cut

sub clear_history {
  shift;
  @readline::rl_History = ();
  $readline::rl_HistoryIndex = $readline::rl_history_length = 0;
}

sub history_list
{
    @readline::rl_History[1..$#readline::rl_History]
}

=head2 remove_history

C<remove_history($which)>

Remove history element C<$which> from the history. The removed
element is returned.

=cut

sub remove_history {
  shift;
  my $which = $_[0];
  return undef if
    $which < 0 || $which >= $readline::rl_history_length ||
      $attribs{history_length} ==  0;
  my $removed = splice @readline::rl_History, $which, 1;
  $readline::rl_history_length--;
  $readline::rl_HistoryIndex = $readline::rl_history_length if
    $readline::rl_history_length < $readline::rl_HistoryIndex;
  return $removed;
}

=head2 replace_history_entry

C<replace_history_entry($which, $data)>

Make the history entry at C<$which> have C<$data>.  This returns the old
entry. In the case of an invalid C<$which>, $<undef> is returned.

=cut

sub replace_history_entry {
  shift;
  my ($which, $data) = @_;
  return undef if $which < 0 || $which >= $readline::rl_history_length;
  my $replaced = splice @readline::rl_History, $which, 1, $data;
  return $replaced;
}

=head2 stifle_history

C<stifle_history($max)>

Stifle or put a cap on thethe history list, remembering only C<$max>
number of lines.

=cut

sub stifle_history {
  shift;
  my $max = shift;
  $max = 0 if !defined($max) || $max < 0;

  if (scalar @readline::rl_History > $max) {
      splice @readline::rl_History, $max;
      $attribs{history_length} = scalar @readline::rl_History;
  }

  $readline::history_stifled = 1;
  $readline::rl_max_input_history = $max;
}

=head2 unstifle_history

C<unstifle_history>

Unstifle or remove limit the history list.

Theprevious maximum number of history entries is returned.  The value
is positive if the history was stifled and negative if it wasn't.

=cut

sub unstifle_history {
  if ($readline::history_stifled) {
    $readline::history_stifled = 0;
    return (scalar @readline::rl_History);
  } else {
    return - scalar @readline::rl_History;
  }
}

=head2 history_is_stifled

C<history_is_stifled>

Returns I<true> if saved history has a limited (stifled) or I<false>
if there is no limit (unstifled).

=cut

sub history_is_stifled {
  shift;
  $readline::history_stifled ? 1 : 0;
}

# read_history() and write_history() follow GNU Readline's
# C convention of returning 0 for success and 1 for failure.
#
# ReadHistory and WriteHstory follow Perl's convention of returning 1
# for success and 0 for failure.
# It is a little bit whacky, but this is in fact how Term::ReadLine::Gnu
# works.

sub read_history {
  my $self = shift;
  my $filename = shift;
  open(HISTORY, '<', $filename ) or return 1;
  while (<HISTORY>) { chomp; push @history, $_} ;
  SetHistory($self, @history);
  close HISTORY;
  return 0;
}

sub write_history {
  shift;
  my $filename = shift;
  open(HISTORY, '>', $filename ) or return 1;
  for (@readline::rl_History) { print HISTORY $_, "\n"; }
  close HISTORY;
  return 0;
}

sub ReadHistory {
    ! read_history(@_);
}

sub WriteHistory {
    ! write_history(@_);
}
%features =  (appname => 1, minline => 1, autohistory => 1,
	      getHistory => 1, setHistory => 1, addHistory => 1,
	      readHistory => 1, writeHistory => 1,
	      preput => 1, attribs => 1, newTTY => 1,
	      tkRunning => Term::ReadLine::Stub->Features->{'tkRunning'},
	      ornaments => Term::ReadLine::Stub->Features->{'ornaments'},
	      stiflehistory => 1,
	     );
sub Features { \%features; }
# my %attribs;
tie %attribs, 'Term::ReadLine::Perl5::Tie' or die ;
sub Attribs {
  \%attribs;
}
sub DESTROY {}

package Term::ReadLine::Perl5::AU;

sub AUTOLOAD {
  { $AUTOLOAD =~ s/.*:://; }		# preserve match data
  my $name = "readline::rl_$AUTOLOAD";
  die "Unknown method `$AUTOLOAD' in Term::ReadLine::Perl5" 
    unless exists $readline::{"rl_$AUTOLOAD"};
  *$AUTOLOAD = sub { shift; &$name };
  goto &$AUTOLOAD;
}

package Term::ReadLine::Perl5::Tie;

sub TIEHASH { bless {} }
sub DESTROY {}

sub STORE {
  my ($self, $name) = (shift, shift);
  $ {'readline::rl_' . $name} = shift;
}

sub FETCH {
  my ($self, $name) = (shift, shift);
  $ {'readline::rl_' . $name};
}

1;

__END__

=head1 AUTHORS

Jordan M. Adler
Rocky Bernstein
Ilya Zakharevich (Term::ReadLine::Perl)
Jeffrey Friedl (Original Perl4 code)

=head1 SEE ALSO

=over 4

=item GNU Readline Library Manual

=item GNU History Library Manual

=item L<Term::ReadLine>

=item L<Term::ReadLine::readline>

=item L<Term::ReadLine::Perl>

=item L<Term::ReadLine::Gnu>

=back

=cut
