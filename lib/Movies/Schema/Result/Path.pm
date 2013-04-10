package Movies::Schema::Result::Path;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("path");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "range", {
	data_type => "TINYINT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 3
    },
    "note", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 125
    },
    "storage", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 125
    },
    "file_name", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    },
    "file_size", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "file_len", {
	data_type => "SMALLINT",
	extra => { unsigned => 1 },
	default_value => 0,
	is_nullable => 0,
	size => 5
    },
    "audio", {
	data_type => "VARCHAR",
	default_value => "",
	is_nullable => 0,
	size => 64
    },
    "video", {
	data_type => "VARCHAR",
	default_value => "",
	is_nullable => 0,
	size => 64
    },
    "counter", {
	data_type => "INT",
	extra => { unsigned => 1 },
	default_value => 0,
	is_nullable => 0,
	size => 10
    },
);
__PACKAGE__->set_primary_key("no", "range");
#__PACKAGE__->utf8_columns(qw/note file_name/); # deprecated module UTF8Columns

1;
