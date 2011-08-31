use strict;
use warnings;
use Test::More;
use Try::Tiny;

BEGIN { use_ok 'LaTeX::Render::Image::Exception' }

my $classes = {
    # classname postfix => expected description
    General => 'general exception',
    Usage   => 'programmer exception',
    File    => 'filesystem exception',
    IPC     => 'IPC exception',
};

for my $class_postfix (keys %$classes) {
    my $class = 'LaTeX::Render::Image::Exception::' . $class_postfix;
    my $e;
    try {
        $class->throw(error => "test $class_postfix");
    } catch {
        $e = $_;
    };
    isa_ok($e,  $class);
    is($e->error, "test $class_postfix", "$class_postfix exception: error");
    my $expected_desc = $classes->{$class_postfix};
    like($e->description , qr/$expected_desc/i, "$class_postfix exception: description");
}

{
    my $e;
    try {
        LaTeX::Render::Image::Exception::IPC->throw(
            error  => 'errmsg',
            output => 'buffer',
        );
    } catch {
        $e = $_;
    };
    is($e->output, 'buffer', 'IPC exception has output field');
}

done_testing();
