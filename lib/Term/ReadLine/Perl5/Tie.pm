use strict; use warnings;
package Term::ReadLine::Perl5::Tie;

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
