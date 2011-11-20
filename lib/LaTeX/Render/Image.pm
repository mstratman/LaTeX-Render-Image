package LaTeX::Render::Image;
# Very simple wrapper around CLI programs
use Any::Moose;

our $VERSION = '0.01';

use LaTeX::Render::Image::Exception;
use IO::File;
use IPC::Cmd qw(can_run run);
use File::Temp ();
use File::Spec ();
use File::Path ();
use Try::Tiny;
use Scalar::Util qw(blessed);
use namespace::autoclean;

=head1 NAME

LaTeX::Render::Image - Commandline wrapper to render images from LaTeX

=head1 SYNOPSIS

    $tex = LaTeX::Render::Image->new;
    $img_data = $tex->render($latex_markup);
    $tex->render_file($latex_markup, 'file.png');

    # Equation is just a LaTeX::Render::Image class with
    # the Document and Equation convenience roles. (see the SEE ALSO)
    $equation = LaTeX::Render::Image::Equation->new;
    $img_data = $equation->render_equation('\frac{x^2}{y}');
    $equation->render_equation_to_file('\frac{x^2}{y}', 'file.png');

=head1 DESCRIPTION

This set of modules is a ridiculously simple wrapper around commandline
utilities for rendering images from LaTeX markup.

It's only real purpose is to provide some object oriented sugar to make
the code cleaner and more extensible.

It uses L<Any::Moose> so it will play well with your L<Moose> or
L<Mouse> code, and be easy to customize without digging into the guts.

=head1 ATTRIBUTES

=cut

=head2 latex

The path to the C<latex> commandline utility.  If it is in your
path, it will be found automatically.

=cut

has 'latex' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_latex',
);
sub _build_latex { can_run('latex') // '' }

=head2 dvi_convert

The path to the program which turns the DVI file into an image.

Default is I<dvipng>

=cut

has 'dvi_convert' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_dvi_convert',
);
sub _build_dvi_convert { can_run('dvipng') // '' }

=head2 dvi_convert_options

Arrayref of commandline options to pass to the L</dvi_convert> utility.

Default is 

    [ '-T' => 'tight', '-bg' => 'Transparent', '-Q' => '5' ]

=cut

has 'dvi_convert_options' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_dvi_convert_options',
);
sub _build_dvi_convert_options {
    [ '-T' => 'tight', '-bg' => 'Transparent', '-Q' => '5' ]
}

=head2 file_extension

Extension of the output file.

Default is I<png>.

=cut

has 'file_extension' => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'png',
);

=head2 mime_type

Mime type for the output file.

Default is I<image/png>.

=cut

has 'mime_type' => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_mime_type',
);
sub _build_mime_type { 'image/' . lc $_[0]->file_extension }

=head1 METHODS

=head2 render ($latex)

This method renders LaTeX to an image, and returns the contents of the image,
or undef on failure.

This can throw exceptions.

=cut

sub render
{
    my ($self, $input) = @_;
    # This is kind of a hack.
    # Ideally it should render without a writing then reading a temporary file.

    my $outdir;
    try {
        $outdir = File::Temp->newdir('TeX2ImageXXXXXXX',
            CLEANUP => 0,
        );
    } catch {
        LaTeX::Render::Image::Exception::File->throw(error => "Cannot create new tmp dir: $_");
    };
    my $outfile = File::Spec->catfile($outdir, 'out.' . $self->file_extension);

    $outfile = $self->render_file($input, $outfile);
    return undef unless defined $outfile;

    my $fh = IO::File->new($outfile);
    unless (defined $fh) {
        LaTeX::Render::Image::Exception::File->throw(error => "Cannot read from rendered file $outfile: $!");
    }
    binmode $fh;
    my $buffer;
    my $rv;
    while (read($fh, $buffer, 65536) and $rv .= $buffer) {}
    $fh->close();

    $self->_remove_temp_dir($outdir);

    return $rv;
}

=head2 render_file ($latex, $optional_output_filename)

This method renders LaTeX to an image file.

Returns the output filename, or undef on error.
C<$optional_output_filename> is optional, defaults to a tmp file (which
you must delete, along with its parent directory).

This can throw exceptions.

=cut

sub render_file
{
    my ($self, $input, $outfile) = @_;

    my $tmpdir;
    try {
        $tmpdir = File::Temp->newdir('TeX2ImageXXXXXXX',
            CLEANUP => 0,
        );
    } catch {
        LaTeX::Render::Image::Exception::File->throw(error => "Cannot create new tmp dir: $_");
    };

    unless (defined $outfile) {
        my $outdir = File::Temp->newdir('TeX2ImageXXXXXXX',
            CLEANUP => 0,
        );
        $outfile = File::Spec->catfile($outdir, 'out.' . $self->file_extension);
    }

    my $tex_file = File::Spec->catfile($tmpdir, 'out.tex');
    my $fh = IO::File->new($tex_file, "w");
    unless (defined $fh) {
        LaTeX::Render::Image::Exception::File->throw(error => "Cannot write to $tex_file: $!");
    }
    print $fh $input;
    $fh->close();

    my $latex = can_run($self->latex);
    unless ($latex) {
        LaTeX::Render::Image::Exception::IPC->throw(error => "Cannot find latex binary: " . $self->latex);
    }

    my $dvipng = can_run($self->dvi_convert);
    unless ($dvipng) {
        LaTeX::Render::Image::Exception::IPC->throw(error => "Cannot find dvi_convert binary: " . $self->dvi_convert);
    }

    try {
        my ($success, $error_message, $full_buf) = run(
            command => [
                $latex,
                '-interaction'      => 'batchmode',
                '-output-directory' => $tmpdir,
                '-output-format'    => ' dvi',
                $tex_file,
            ], 
        );
        unless ($success) {
            LaTeX::Render::Image::Exception::IPC->throw(error => "$latex failed with '$error_message'", output => $buffer);
        }
    } catch {
        blessed $_ ?  $_->rethrow : LaTeX::Render::Image::Exception::IPC->throw(error => "run() died: $_");
    };

    my $dvi_file = File::Spec->catfile($tmpdir, 'out.dvi');
    # We expect latex to have created the $dvi_file
    unless (-e $dvi_file) {
        LaTeX::Render::Image::Exception::General->throw(error => "$latex did not generate dvi file '$dvi_file': $out_and_err");
    }

    try {
        my ($success, $error_message, $full_buf) = run(
            command => [
                $dvipng,
                $dvi_file,
                @{ $self->dvi_convert_options },
                '-o' => $outfile,
            ],
        );
        unless ($success) {
            LaTeX::Render::Image::Exception::IPC->throw(error => "$dvipng failed with '$error_message'", output => $buffer);
        }
    } catch {
        blessed $_ ?  $_->rethrow : LaTeX::Render::Image::Exception::IPC->throw(error => "run() died: $_");
    };

    unless (-e $outfile) {
        LaTeX::Render::Image::Exception::General->throw(error => "$dvipng did not generate outfile '$outfile': $out_and_err");
    }

    $self->_remove_temp_dir($tmpdir);
    return $outfile;
}

sub _remove_temp_dir {
    my ($self, $outdir) = @_;
    my $err;
    File::Path::remove_tree($outdir, { error => \$err });
    if (@$err) {
        for my $diag (@$err) {
            my ($file, $message) = %$diag;
            if ($file eq '') {
                warn "remove_tree() general error: $message\n";
            } else {
                warn "remove_tree() problem unlinking $file: $message\n";
            }
        }
    }
}

=head1 SEE ALSO

L<LaTeX::Render::Image::Equation>

L<LaTeX::Render::Image::Role::Equation>

L<LaTeX::Render::Image::Role::Document>

=cut

no Any::Moose;
1;
__END__

=head1 AUTHOR

Mark A. Stratman E<lt>stratman@gmail.comE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
