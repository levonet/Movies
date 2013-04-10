package Movies::Schema::ResultSet::Cast;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;


sub ql_actor {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.actor', 'me.actor' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.actor' ]
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
