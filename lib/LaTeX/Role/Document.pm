package LaTeX::Role::Document;
use Any::Moose 'Role';

has 'document_header' => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_header',
);
has 'document_footer' => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_footer',
);

sub wrap_document {
    my ($self, $text) = @_;
    return $self->document_header . $text . $self->document_footer;
}

sub _build_header {
    my $self = shift;
    return '\documentclass[12pt]{article}'
        . q(
\usepackage{color}
\usepackage[utf8]{inputenc}
\usepackage{amssymb}
\usepackage{amsmath}
\pagestyle{empty}
\begin{document}
);
}

sub _build_footer {
    return q(
\end{document}
);
}

no Any::Moose;
1;
__END__

=head1 AUTHOR

Mark A. Stratman E<lt>stratman@gmail.comE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
