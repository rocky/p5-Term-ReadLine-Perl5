#!/usr/bin/env perl
#  Copyright (C) 2013 Rocky Bernstein <rocky@cpan.org>
#

use strict;
use warnings;
use Module::Build;
use Config;
use File::Basename;
use File::Spec;

my $lib = File::Spec->catfile(dirname(__FILE__), 'lib');
unshift @INC, $lib;
require Term::ReadLine::Perl5;

my $release_status = ($Term::ReadLine::Perl5::VERSION =~ /_/) ?
    'testing' : 'stable';

my $builder = Module::Build->new(
    module_name         => 'Term::ReadLine::Perl5',
    add_to_cleanup      => ['Term-ReadLine-Perl5*', 'tmp*', '.history.text',
			    'pod2htm*.tmp'],
    create_makefile_pl  => 'passthrough',
    dist_abstract       => 'Perl5 version of GNU ReadLine.',
    dist_author         => 'Rocky Bernstein <rocky@cpan.org>',
    dist_version_from   => 'lib/Term/ReadLine/Perl5.pm',
    license             => 'perl',
    needs_compiler      => 0,
    release_status      => $release_status,

    meta_merge => {
	resources => {
	    bugtracker  => 'https://github.com/rocky/p5-Term-ReadLine-Perl5/issues',
	    repository  => 'http://github.com/rocky/p5-Term-ReadLine-Perl5'
	}
    },

    configure_requires => {
	'Module::Build'           => '0.4.004',  # Min "test_requires"
	'perl'                    => '5.008008',
    },
    test_requires => {
        'Test::More'              => 0.81,
        'rlib'                    => '0.02',
    },
    requires => {
        'version'                 => 0,
	'File::HomeDir'           => 0.54,
	'File::Spec'              => 0,
        'Term::ReadKey'           => 0,
    },
    sign                => ($ENV{PERL_MB_NOSIGN} ? 0 : 1),
    );

$builder->create_build_script();
