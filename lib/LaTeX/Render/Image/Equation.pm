package LaTeX::Render::Image::Equation;
use Any::Moose;
extends 'LaTeX::Render::Image';
with ('LaTeX::Role::Document', 'LaTeX::Role::Equation');

no Any::Moose;
1;
__END__

=head1 AUTHOR

Mark A. Stratman E<lt>stratman@gmail.comE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
