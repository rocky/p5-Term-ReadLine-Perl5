use strict; use warnings;
use version;

package Term::ReadLine::Perl5::Tie;

# version might not be below other places in this routine
# no critic
our $VERSION = '1.32';

sub TIEHASH { bless {} }

sub STORE {
  my ($self, $name) = (shift, shift);
  no strict;
  no warnings 'once';
  $ {'Term::ReadLine::Perl5::readline::rl_' . $name} = shift;
}

sub FETCH {
  my ($self, $name) = (shift, shift);
  no strict;
  $ {'Term::ReadLine::Perl5::readline::rl_' . $name};
}

1;
