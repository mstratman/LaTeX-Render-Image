package LaTeX::Render::Image::Exception;

use Exception::Class (
    'LaTeX::Render::Image::Exception::General' => {
        description => 'General exception',
    },
    'LaTeX::Render::Image::Exception::File' => {
        isa         => 'LaTeX::Render::Image::Exception::General',
        description => 'Filesystem exception',
    },
    'LaTeX::Render::Image::Exception::IPC' => {
        isa         => 'LaTeX::Render::Image::Exception::General',
        description => 'IPC exception',
        fields      => [ qw(output) ],
    },
    'LaTeX::Render::Image::Exception::Usage' => {
        isa         => 'LaTeX::Render::Image::Exception::General',
        description => 'Programmer exception',
    },
);

1;
