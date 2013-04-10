package Movies::Schema::Result::General;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("general");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1, zerofill => 1},
	is_nullable => 0,
	default_value => undef,
	size => 10,
	is_auto_increment => 1
    },
    "date_add", {
	data_type => "DATE",
	is_nullable => 0,
	default_value => "0000-00-00"
    },
    "orig_lang", {
	data_type => "CHAR",
	is_nullable => 0,
	default_value => "",
	size => 2
    },
    "orig_title", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 255
    },
    "quality", {
	data_type => "TINYINT",
	extra => { unsigned => 1 },
	default_value => 0,
	is_nullable => 0,
	size => 3
    },
    "category", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 5
    },
    "ryear", {
	data_type => "YEAR",
	is_nullable => 0,
	default_value => "0000",
	size => 4
    },
    "runtime", {
	data_type => "SMALLINT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 5
    },
    "viewed", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
);
__PACKAGE__->set_primary_key("no");
#__PACKAGE__->utf8_columns(qw/orig_title/); # deprecated module UTF8Columns

__PACKAGE__->has_many(descriptions => 'Movies::Schema::Result::Description', 'no');
__PACKAGE__->has_many(genres => 'Movies::Schema::Result::Genre', 'no');
__PACKAGE__->has_many(actors => 'Movies::Schema::Result::Cast', 'no');
__PACKAGE__->has_many(paths => 'Movies::Schema::Result::Path', 'no');
__PACKAGE__->has_many(views => 'Movies::Schema::Result::View', 'no');
__PACKAGE__->has_many(sidx => 'Movies::Schema::Result::SearchIndex', 'no');

sub desc_langs {
    my ( $self ) = @_;

    return $self->result_source->resultset->search(
	{   'me.no'	=> $self->id },
	{
	    join	=> 'descriptions',
	    select	=> [ 'descriptions.desc_lang', 'descriptions.title' ],
	    as		=> [ 'lang', 'title' ],
	    order_by	=> [ { -desc => 'descriptions.desc_lang' } ]
	}
    )->all;
}

sub cast {
    my ( $self, $lang ) = @_;

    return $self->result_source->resultset->search(
	{
	    'me.no'	=> $self->id,
	    'actors.desc_lang'	=> $lang
	}, {
	    join	=> 'actors',
	    select	=> [ 'actors.actor', 'actors.role' ],
	    as		=> [ 'actor', 'role' ]
	}
    )->all;
}

sub view_state {
    my ( $self, $uid ) = @_;

    return defined $self->result_source->resultset->search(
	{
	    'me.no'	=> $self->id,
	    'views.user_id'	=> $uid
	}, {
	    join	=> 'views',
	    select	=> [ '1' ]
	}
    )->single;
}

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index( name => 'idx_date_add', fields => ['date_add'] );
    $sqlt_table->add_index( name => 'idx_orig_title', fields => ['orig_title'] );
#    $sqlt_table->add_index( name => 'idx_quality', fields => ['quality'] );
#    $sqlt_table->add_index( name => 'idx_category', fields => ['category'] );
    $sqlt_table->add_index( name => 'idx_ryear', fields => ['ryear'] );
}

1;
