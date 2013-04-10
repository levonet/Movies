package Movies::Schema::ResultSet::General;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 list_new

Get list from Gneral by precondition.

=cut

sub list_new {
    my ( $self, $conditions, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear' ],
	    order_by	=> [ { -desc => [qw/ me.date_add me.no /] } ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

sub list_ctg_by {
    my ( $self, $conditions, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    join	=> 'genres',
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear' ],
	    order_by	=> [ { -desc => [qw/ me.ryear me.orig_title /] } ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

sub list_alphabet_by {
    my ( $self, $conditions, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    join	=> 'descriptions',
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear' ],
	    order_by	=> [ 'descriptions.title', { -desc => [qw/ me.ryear /] } ],
	    group_by	=> [ 'me.no' ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

=head2 alphabet_group

Group orig_title by first char

=cut

sub alphabet_group {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> \[ 'left(ucase(me.orig_title),1) as letter' ],
	    as		=> [ 'letter' ],
	    group_by	=> [ 'letter' ]
	}
    );
}

sub list_actor_by {
    my ( $self, $conditions, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    join	=> 'actors',
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear' ],
	    group_by	=> [ 'me.no' ],
	    order_by	=> [ { -desc => [qw/ me.ryear /] }, 'me.orig_title' ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

sub group_years {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.ryear' ],
	    as		=> [ 'ryear' ],
	    group_by	=> [ 'me.ryear' ]
	}
    );
}

sub list_release_by {
    my ( $self, $conditions, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear' ],
	    order_by	=> [ { -desc => [qw/ me.date_add me.no /] } ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

sub list_search {
    my ( $self, $conditions, $threshold, $rows, $page ) = @_;

    return $self->search(
	$conditions,
	{
	    join	=> { 'sidx' => 'sdict' },
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.ryear', \[ 'sum(sdict.weight) AS relevant' ] ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'ryear', 'relevant' ],
	    order_by	=> [ { -desc => [ 'relevant' ] } ],
	    group_by	=> [ 'me.no' ],
	    having	=> { 'sum(sdict.weight)' => { '>=', $threshold } },
	    rows	=> $rows,
	    page	=> $page
	}
    );
}

sub list_full {
    my ( $self, $rows, $page ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.no', 'me.date_add', 'me.orig_title', 'me.ryear' ],
	    as		=> [ 'no', 'date_add', 'orig_title', 'ryear' ],
	    order_by	=> [ { -desc => [qw/ me.no /] } ],
	    rows	=> $rows,
	    page	=> $page
	}
    );
}


sub for_index {
    my ( $self, $id ) = @_;

    return $self->search(
	{
	    'me.no'	=> $id
	}, {
	    select	=> [ 'me.orig_title' ],
	    as		=> [ 'orig_title' ]
	}
    );
}

=head2 view

Get description for view by id and lang.

=cut

sub view {
    my ( $self, $id, $desc_lang ) = @_;

    return $self->search(
	{
	    'me.no'			=> $id,
	    'descriptions.desc_lang'	=> $desc_lang,
	}, {
	    join	=> 'descriptions',
	    select	=> [ 'me.no', 'me.orig_lang', 'me.orig_title', 'me.quality', 'me.category', 'me.ryear', 'me.runtime', 'me.viewed',
			     'descriptions.title', 'descriptions.language', 'descriptions.production',
			     'descriptions.director', 'descriptions.country', 'descriptions.synopsis' ],
	    as		=> [ 'no', 'orig_lang', 'orig_title', 'quality', 'category', 'ryear', 'runtime', 'viewed',
			     'loc_title', 'language', 'production', 'director', 'country', 'synopsis' ],
	}
    );
}

sub ql_orig_lang {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.orig_lang', 'me.orig_lang' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.orig_lang' ]
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
