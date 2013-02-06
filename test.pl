# Give an argument to use stdin, stdout instead of console
# If argument starts with /dev, use it as console
BEGIN{ $ENV{PERL_RL} = 'Perl' };	# Do not test TR::Gnu !
use Term::ReadLine;
if (!@ARGV) {
  $term = new Term::ReadLine 'Simple Perl calc';
} elsif ($ARGV[0] =~ m|^/dev|) {
  open(IN,"<$ARGV[0]");
  open(OUT,">$ARGV[0]");
  $term = new Term::ReadLine 'Simple Perl calc', \*IN, \*OUT;
} else {
  $term = new Term::ReadLine 'Simple Perl calc', \*STDIN, \*STDOUT;
}
$prompt = "Enter arithmetic or Perl expression: ";
$OUT = $term->OUT || STDOUT;
%features = %{ $term->Features };
if (%features) {
  @f = %features;
  print $OUT "Features present: @f\n";
  #$term->ornaments(1) if $features{ornaments};
} else {
  print $OUT "No additional features present.\n";
}
while ( defined ($_ = $term->readline($prompt, "exit")) ) {
  $res = eval($_);
  warn $@ if $@;
  print $OUT $res, "\n" unless $@;
  $term->addhistory($_) if /\S/ and !$features{autohistory};
}

