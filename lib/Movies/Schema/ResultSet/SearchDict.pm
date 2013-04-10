package Movies::Schema::ResultSet::SearchDict;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 max_weight

Check maximal weight of query

=cut

sub max_weight {
    my ( $self, $conditions ) = @_;

    return $self->search(
	$conditions,
	{
	    select	=> [ { 'sum' => [ 'weight' ] } ],
	    as => [ 'maxweight' ]
	}
    )->single;
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
