package Movies::Schema::ResultSet::Genre;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 view_state

Chek user by id.

=cut

sub group_category {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.genreid' ],
	    as		=> [ 'genreid' ],
	    group_by	=> [ 'me.genreid' ]
	},
    );
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
