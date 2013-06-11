use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    DISTNAME	 => 'Term-ReadLine-Perl5',
    NAME	     => 'Term::ReadLine::Perl5',
    AUTHOR       => 'Rocky Bernstein <rocky@cpan.org>',
    VERSION_FROM => 'lib/Term/ReadLine/readline.pm',
    linkext      => {LINKTYPE => '' },
    clean        => {
    	FILES => [".history_test", 'pod2htmd.tmp', 'pod2htmi.tmp']
    },
    BUILD_REQUIRES => {
        'rlib'       => '0.02',
        'Test::More' => '0.81',
    },
    LICENSE          => 'perl',
    MIN_PERL_VERSION => 5.008008,
    # dist => {COMPRESS=>'gzip -9f', SUFFIX=>'gz',
    #		     DIST_DEFAULT => 'all uutardist'},
    );
