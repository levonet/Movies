package Movies::Schema::Result::Description;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("description");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "desc_lang", {
	data_type => "CHAR",
	is_nullable => 0,
	default_value => "",
	size => 2
    },
    "title", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 255
    },
    "language", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 80
    },
    "production", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 240
    },
    "director", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    },
    "country", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 80
    },
    "synopsis", {
	data_type => "BLOB",
	default_value => undef,
	is_nullable => 0
    },
);
__PACKAGE__->set_primary_key("no", "desc_lang");
#__PACKAGE__->utf8_columns(qw/title language production director country synopsis/); # deprecated module UTF8Columns

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index( name => 'idx_no', fields => ['no'] );
    $sqlt_table->add_index( name => 'idx_title', fields => ['title'] );
    # For query list
    $sqlt_table->add_index( name => 'idx_desc_lang', fields => ['desc_lang'] );
    $sqlt_table->add_index( name => 'idx_language', fields => ['language'] );
    $sqlt_table->add_index( name => 'idx_production', fields => ['production'] );
    $sqlt_table->add_index( name => 'idx_director', fields => ['director'] );
    $sqlt_table->add_index( name => 'idx_country', fields => ['country'] );
}

1;
