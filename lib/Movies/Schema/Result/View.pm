package Movies::Schema::Result::View;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("view");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "user_id", {
	data_type => "INT",
	is_nullable => 0,
	default_value => undef,
	size => 11
    },
);

__PACKAGE__->belongs_to(user => 'Movies::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(general => 'Movies::Schema::Result::General', 'no');

1;
