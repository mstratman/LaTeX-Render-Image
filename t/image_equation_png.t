use strict;
use warnings;
use Test::More;
use Try::Tiny;

BEGIN { use_ok 'LaTeX::Render::Equation::PNG' }

my $l = new_ok('LaTeX::Render::Image', [
    latex => 'latex_does_not_exist',
]);
my $had_error;
try {
    $l->render('\BADDOC');
} catch {
    $had_error = 1;
    diag("TODO: Check the exception extra: " . $_->extra);
};
ok($had_error, 'Died with bad latex path');

done_testing;
