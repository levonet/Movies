package Movies::Schema::ResultSet::User;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 get_user

Get a user by login.

=cut

sub get_user {
    my ( $self, $login ) = @_;

    return $self->search( { login => $login } )->single;
}

sub users_by_id {
    my ( $self, $rows, $page ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.id', 'me.login', 'me.name', 'me.email_address', 'me.login_time', 'me.login_host', 'active' ],
	    order_by	=> [ 'me.id' ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
