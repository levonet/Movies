package Movies::Schema::Result::Cast;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("cast");
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
    "actor", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    },
    "role", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    },
);
#__PACKAGE__->utf8_columns(qw/actor role/); # deprecated module UTF8Columns

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index( name => 'idx_no_desc_lang', fields => ['no', 'desc_lang'] );
    $sqlt_table->add_index( name => 'idx_actor', fields => ['actor'] );
}

1;
