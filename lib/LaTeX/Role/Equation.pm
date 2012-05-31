package LaTeX::Role::Equation;
use Any::Moose 'Role';

# large stand-alone equation 
sub wrap_equation
{
    my $self = shift;
    my $equation = $self->sanitize_equation(shift);
    unless ($equation =~ /^\s*\\begin\{align\*?\}/ && $equation =~ /\\end\{align\*?\}\s*$/) {
        $equation = q($\displaystyle ) . $equation . q( $);
    }
    return $equation;
}

# Smaller inline equation (e.g. within a sentence).
sub wrap_inline_equation
{
    my $self = shift;
    my $equation = $self->sanitize_equation(shift);
    $equation =~ s/^\s+//;
    $equation =~ s/\s+$//;
    $equation = '$ ' . $equation unless $equation =~ /^\$/;
    $equation .= ' $' unless $equation =~ /\$$/;
    return $equation;
}

sub sanitize_equation
{
    my $self = shift;
    my $eq = shift || '';
    $eq =~ s/\$/\\\$/g;
    return $eq;
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
