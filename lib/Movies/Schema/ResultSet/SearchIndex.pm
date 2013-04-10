package Movies::Schema::ResultSet::SearchIndex;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 max_weight

Check maximal weight of query

=cut

sub relevant {
    my ( $self, $sid ) = @_;

    my $row = $self->search(
	{ sid => $sid },
	{
	    select	=> [ \[ 'round( 1 / count(1), 9 )' ] ],
	    as => [ 'weight' ]
	}
    )->single;

    return defined $row ? $row->get_column('weight') : undef;
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
