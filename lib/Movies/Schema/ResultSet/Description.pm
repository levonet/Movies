package Movies::Schema::ResultSet::Description;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 titles_by_id

Filter descriptions by no. Get desc_lang and title

=cut

sub titles_by_id {
    my ( $self, $id ) = @_;

    return $self->search(
	{ 'me.no'	=> $id },
	{
	    select	=> [ 'me.desc_lang', 'me.title' ],
	    as		=> [ 'desc_lang', 'title' ]
	}
    );
}


=head2 alphabet_group

Group title by first char

=cut

sub alphabet_group {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
#	    select	=> [ { 'left' => [ {'ucase' => 'title'}, 1 ] } ],
	    select	=> \[ 'left(ucase(me.title),1) as letter' ],
	    as		=> [ 'letter' ],
	    group_by	=> [ 'letter' ]
	}
    );
}


=head2 langs

Description langs

=cut

sub langs {
    my ( $self, $id ) = @_;

    return $self->search(
	{ 'me.no'	=> $id },
	{
	    select	=> [ 'me.desc_lang' ],
	    as		=> [ 'desc_lang' ]
	}
    );
}

sub for_index {
    my ( $self, $id ) = @_;

    return $self->search(
	{
	    'me.no'	=> $id
	}, {
	    select	=> [ 'me.title', 'me.director' ],
	    as		=> [ 'title', 'director' ]
	}
    );
}

sub ql_desc_lang {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.desc_lang', 'me.desc_lang' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.desc_lang' ]
	}
    );
}

sub ql_language {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.language', 'me.language' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.language' ]
	}
    );
}

sub ql_production {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.production', 'me.production' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.production' ]
	}
    );
}

sub ql_director {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.director', 'me.director' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.director' ]
	}
    );
}

sub ql_country {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select	=> [ 'me.country', 'me.country' ],
	    as		=> [ 'val', 'name' ],
	    group_by	=> [ 'me.country' ]
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
