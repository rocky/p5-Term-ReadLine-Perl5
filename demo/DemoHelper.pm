use strict; use warnings;
use Exporter;
use Array::Columnize;

package DemoHelper;

use rlib '../lib';
use Term::ReadLine::Perl5;

use vars qw(@EXPORT %commands @commands &cmd_resetTTY &print_features);
@EXPORT = qw(%commands @commands &cmd_resetTTY &print_features);

my ($num_cols,$num_rows) =  Term::ReadKey::GetTerminalSize(\*STDOUT);

sub print_features($) {
    my $term = shift;
    my @features = sort keys %{ $term->Features; };
    print "Features:\n";
    print Array::Columnize::columnize(\@features,
				      {displaywidth => $num_cols,
				       colsep => ' ',
				       lineprefix => '  '});
}

sub cmd_ResetTTY {
    Term::ReadLine::Perl5::readline::ResetTTY();
};

sub cmd_SetTTY {
    Term::ReadLine::Perl5::readline::SetTTY();
};

sub cmd_exit {
};

sub cmd_help {
    print "Commands:\n";
    print Array::Columnize::columnize(\@commands,
				      {displaywidth => $num_cols,
				       colsep => '  ',
				      });
};

sub cmd_init {
    Term::ReadLine::Perl5::readline::init();
};
sub cmd_preinit {
    print "preinit called!\n";
    Term::ReadLine::Perl5::readline::preinit();
};

sub cmd_redisplay {
    Term::ReadLine::Perl5::readline::redisplay();
};

sub cmd_rl_filename_list {
};

sub cmd_rl_set {
};
sub cmd_tilde_complete {
};

%commands = (
    'ResetTTY' => \&cmd_ResetTTY,
    'SetTTY' => \&cmd_SetTTY,
    'exit' => \&cmd_exit,
    'help' => \&cmd_help,
    'init' => \&cmd_init,
    'preinit' => \&cmd_preinit,
    'redisplay' => \&cmd_redisplay,
    'rl_filename_list' => \&cmd_rl_filename_list,
    'rl_set' => \&cmd_rl_set,
    'tilde_complete' => \&cmd_tilde_complete
    );

@commands = sort keys %commands;

1;
