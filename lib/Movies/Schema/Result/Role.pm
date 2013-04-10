package Movies::Schema::Result::Role;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
    "id", {
	data_type => "INT",
	is_nullable => 0,
	default_value => undef,
	size => 11,
	is_auto_increment => 1
    },
    "role", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 16
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( role => [qw/role/], );

__PACKAGE__->has_many(map_user_roles => 'Movies::Schema::Result::UserRole', 'role_id');

1;
