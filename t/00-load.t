#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'LaTeX::Render::Image' ) || print "Bail out!\n";
}

diag( "Testing LaTeX::Render::Image $LaTeX::Render::Image::VERSION, Perl $], $^X" );
