use strict;
use warnings;
use Test::More;
use Try::Tiny;

BEGIN { use_ok 'LaTeX::Render::Image::Equation' }

# TODO: Make this work... from SYNOPSIS
#    $tex = LaTeX::Render::Image->new;
#    $img_data = $tex->render($latex_markup);
#    $tex->render_file($latex_markup, 'file.png');
#
#    # Equation is just a LaTeX::Render::Image class with
#    # the Document and Equation convenience roles. (see the SEE ALSO)
#    $equation = LaTeX::Render::Image::Equation->new;
#    $img_data = $equation->render_equation('\frac{x^2}{y}');
#    $equation->render_equation_to_file('\frac{x^2}{y}', 'file.png');

my $l = new_ok('LaTeX::Render::Image::Equation', [
    latex => 'latex_does_not_exist',
]);
my $had_error;
try {
    $l->render('\BADDOC');
} catch {
    $had_error = 1;
    diag("TODO: Check the exception extra: " . $_->output);
};
ok($had_error, 'Died with bad latex path');

done_testing;
