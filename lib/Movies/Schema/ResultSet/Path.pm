package Movies::Schema::ResultSet::Path;

use strict;
use warnings;
use parent qw/Movies::Schema::Base::ResultSet/;

=head2 state

Get files size and number of files.

=cut

sub state {
    my ( $self ) = @_;

    return $self->search(
	undef,
	{
	    select => [
		{ 'sum' => [ 'file_size' ] },
		{ 'sum' => [ '1' ] }
	    ],
	    as => [ 'files_sz', 'files_cnt' ]
	}
    )->single;
}

=head2 paths

Get list from Path by id.

=cut

sub paths {
    my ( $self, $id ) = @_;

    return $self->search(
	{ 'me.no'	=> $id },
	{
	    select	=> [ 'me.range', 'me.note', 'me.storage', 'me.file_name', 'me.file_size', 'me.file_len',
			     'me.audio', 'me.video', 'me.counter' ],
	    as		=> [ 'range', 'note', 'storage', 'file_name', 'file_size', 'file_len', 'audio', 'video', 'counter' ],
	    order_by	=> [ 'me.range' ]
	}
    );
}

sub get {
    my ( $self, $id, $range ) = @_;

    return $self->search(
	{
	    'me.no'	=> $id,
	    'me.range'	=> $range
	}, {
	    select	=> [ 'me.no', 'me.range', 'me.storage', 'me.file_name', 'me.counter' ],
	    as		=> [ 'no', 'range', 'storage', 'file_name', 'counter' ]
	}
    );
}

sub for_index {
    my ( $self, $id ) = @_;

    return $self->search(
	{
	    'me.no'	=> $id
	}, {
	    select	=> [ 'me.note', 'me.file_name' ],
	    as		=> [ 'note', 'file_name' ]
	}
    );
}

sub runtime {
    my ( $self, $id ) = @_;

    my $row = $self->search(
	{
	    'me.no'	=> $id
	},
	{
	    select	=> [ { 'sum' => [ 'me.file_len' ] } ],
	    as		=> [ 'sum_files_len' ]
	}
    )->single;
    return defined $row ? $row->get_column('sum_files_len') : 0;
}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
