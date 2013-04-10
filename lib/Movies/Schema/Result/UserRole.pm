package Movies::Schema::Result::UserRole;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
    "user_id", {
	data_type => "INT",
	is_nullable => 0,
	default_value => 0,
	size => 11
    },
    "role_id", {
	data_type => "INT",
	is_nullable => 0,
	default_value => 1,
	size => 11
    },
);
__PACKAGE__->set_primary_key("user_id", "role_id");

__PACKAGE__->belongs_to(user => 'Movies::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(role => 'Movies::Schema::Result::Role', 'role_id');

1;
