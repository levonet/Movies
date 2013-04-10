package Movies::Schema::Result::LocalTags;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("local_tags");
__PACKAGE__->add_columns(
    "genreid", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10,
    },
    "desc_lang", {
	data_type => "CHAR",
	is_nullable => 0,
	default_value => "",
	size => 2
    },
    "tag", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    }
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index( name => 'idx_genreid', fields => ['genreid'] );
    $sqlt_table->add_index( name => 'idx_genreid_desc_lang', fields => ['genreid', 'desc_lang'] );
}

1;
