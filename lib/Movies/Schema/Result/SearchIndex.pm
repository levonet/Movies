package Movies::Schema::Result::SearchIndex;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("search_index");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "sid", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
);
__PACKAGE__->set_primary_key("no", "sid");

__PACKAGE__->belongs_to(sdict => 'Movies::Schema::Result::SearchDict', 'sid');

1;
