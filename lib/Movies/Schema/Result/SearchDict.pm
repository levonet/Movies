package Movies::Schema::Result::SearchDict;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("search_dict");
__PACKAGE__->add_columns(
    "sid", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => undef,
	size => 10,
	is_auto_increment => 1
    },
    "trigram", {
	data_type => "VARCHAR",
	extra => { binary => 1 },
	default_value => "",
	is_nullable => 0,
	size => 6
    },
    "weight", {
	data_type => "DOUBLE",
	extra => { unsigned => 1 },
	default_value => "0.0",
	is_nullable => 0
    },
);
__PACKAGE__->set_primary_key("sid");
#__PACKAGE__->utf8_columns(qw/trigram/); # deprecated module UTF8Columns
__PACKAGE__->add_unique_constraint( trigram => [qw/trigram/] );

1;
