use inc::Module::Install;

name     'LaTeX-Render-Image';
all_from 'lib/LaTeX/Render/Image.pm';
license  'perl';
homepage 'https://github.com/mstratman/LaTeX-Render-Image';
auto_set_repository;

requires 'namespace::autoclean' => '0.12';
requires 'Any::Moose'           => '0.15';
requires 'Exception::Class' => '1.32';
requires 'File::Path'       => 0;
requires 'File::Spec'       => 0;
requires 'File::Temp'       => 0;
requires 'IO::File'         => 0;
requires 'IPC::Cmd'         => '0.62';
requires 'Scalar::Util'     => 0;
requires 'Try::Tiny'        => '0.09';

test_requires  'Test::More' => 0;

auto_install;
WriteAll;

