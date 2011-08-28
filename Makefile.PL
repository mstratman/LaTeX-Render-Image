use inc::Module::Install;

name     'LaTeX-Render-Image';
all_from 'lib/LaTeX/Render/Image.pm';
author   q{Mark A. Stratman <stratman@gmail.com>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

