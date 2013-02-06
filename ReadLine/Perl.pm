package Term::ReadLine::Perl;

=head1 NAME

Term::ReadLine::Perl - A pure Perl implementation GNU Readline

=head1 SYNOPSIS

  use Term::ReadLine::Perl;
  $term = new Term::ReadLine::Perl 'ProgramName';
  while ( defined ($_ = $term->readline('prompt>')) ) {
    ...
  }

=head1 DESCRIPTION

=head2 Overview

This is a implementation of the GNU Readline/History Library written
entirely in Perl. 

GNU Readline reads lines from an interactive terminal with emacs or vi
editing capabilities. It provides as mechanism for saving history of
previous input. 

This package typically used in command-line interfaces and REPLs (Read,
Eval, Print Loops).

=cut


use Carp;
@ISA = qw(Term::ReadLine::Stub Term::ReadLine::Compa Term::ReadLine::Perl::AU);
#require 'readline.pl';

$VERSION = 1.04;

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


sub new {
  if (defined $term) {
    warn "Cannot create second readline interface, falling back to dumb.\n";
    return Term::ReadLine::Stub::new(@_);
  }
  shift; # Package
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
    $readline::term_OUT = shift;    
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
sub ReadLine {'Term::ReadLine::Perl'}

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

# Place @_ at the end of the history list.
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

sub clear_history {
  shift;
  @readline::rl_History = ();
  $readline::rl_HistoryIndex = $readline::rl_history_length = 0;
}

sub history_list 
{
  @readline::rl_History[1..$#readline::rl_History]
}

# Remove history element WHICH from the history.  The removed
# element is returned. 
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

# Make the history entry at WHICH have DATA.  This returns the old
# entry.  In the case of an invalid WHICH, UNDEF is returned.
sub replace_history_entry {
  shift;
  my ($which, $data) = @_;
  return undef if $which < 0 || $which >= $readline::rl_history_length;
  my $replaced = splice @readline::rl_History, $which, 1, $data;
  return $replaced;
}

# Stifle the history list, remembering only MAX number of lines.
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

# Stop stifling the history.  This returns the previous maximum
# number of history entries.  The value is positive if the history
# was stifled,  negative if it wasn't.
sub unstifle_history {
  if ($readline::history_stifled) {
    $readline::history_stifled = 0;
    return (scalar @readline::rl_History);
  } else {
    return - scalar @readline::rl_History;
  }
}

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
tie %attribs, 'Term::ReadLine::Perl::Tie' or die ;
sub Attribs {
  \%attribs;
}
sub DESTROY {}

package Term::ReadLine::Perl::AU;

sub AUTOLOAD {
  { $AUTOLOAD =~ s/.*:://; }		# preserve match data
  my $name = "readline::rl_$AUTOLOAD";
  die "Unknown method `$AUTOLOAD' in Term::ReadLine::Perl" 
    unless exists $readline::{"rl_$AUTOLOAD"};
  *$AUTOLOAD = sub { shift; &$name };
  goto &$AUTOLOAD;
}

package Term::ReadLine::Perl::Tie;

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

package Term::ReadLine::Compa;

sub get_c {
  my $self = shift;
  getc($self->[0]);
}

sub get_line {
  my $self = shift;
  my $fh = $self->[0];
  scalar <$fh>;
}

1;

__END__

=head1 AUTHORS

Jeffrey Friedl and Ilya Zakharevich

=head1 SEE ALSO

=over 4

=item GNU Readline Library Manual

=item GNU History Library Manual

=item C<Term::ReadLine>

=item C<Term::ReadLine::Perl> (Term-ReadLine-Perl-xx.tar.gz)

=back

=cut
