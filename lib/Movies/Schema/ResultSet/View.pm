package Movies::Schema::ResultSet::View;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 view_state

Chek user by id.

=cut

sub view_state {
    my ( $self, $no, $uid ) = @_;

    return defined $self->search( { 'me.no' => $no, 'me.user_id' => $uid }, { select => [ '1' ] } )->single;
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
