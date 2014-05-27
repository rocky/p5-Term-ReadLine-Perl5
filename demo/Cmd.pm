use strict; use warnings;
use Exporter;
use Array::Columnize;

package Cmd;
use Data::Printer;

use rlib '../lib';
use Term::ReadLine::Perl5;

use vars qw(@EXPORT %commands @commands );
@EXPORT = qw(%commands @commands);

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

sub cmd_read_an_init_file {
    my @args = @_;
    my $filename = $args[1];
    my $result =
	Term::ReadLine::Perl5::readline::read_an_init_file($filename);
    if ($result) {
	print "File $filename read ok\n";
    } else {
	print "File $filename did not read ok\n";
    }
};

sub cmd_redisplay {
    Term::ReadLine::Perl5::readline::redisplay();
};

sub cmd_rl_filename_list {
    my @args = @_;
    my @matches =
	Term::ReadLine::Perl5::readline::rl_filename_list($args[1]);
    p @matches;
};

sub cmd_rl_set {
    my @args = @_;
    if (@args != 3) {
	printf "Was expecting exactly two args, got %d\n", $#args;
    } else  {
	Term::ReadLine::Perl5::readline::rl_set($args[1], $args[2]);
    }
};
sub cmd_tilde_complete {
    my @args = @_;
    my $prefix = (@args == 1) ? '~': $args[1];
    if (substr($prefix, 0, 1) ne '~') {
	print "Tilde expansion expected to start with ~\n";
    } else {
	$prefix = substr($prefix, 1);
	my @matches =
	    Term::ReadLine::Perl5::readline::tilde_complete($prefix);
	p @matches;
    }
};

%commands = (
    'ResetTTY' => \&cmd_ResetTTY,
    'SetTTY' => \&cmd_SetTTY,
    'exit' => \&cmd_exit,
    'help' => \&cmd_help,
    'init' => \&cmd_init,
    'preinit' => \&cmd_preinit,
    'read_an_init_file' => \&cmd_read_an_init_file,
    'redisplay' => \&cmd_redisplay,
    'rl_filename_list' => \&cmd_rl_filename_list,
    'rl_set' => \&cmd_rl_set,
    'tilde_complete' => \&cmd_tilde_complete
    );

@commands = sort keys %commands;

1;
