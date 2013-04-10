package Movies::Schema::Result::Genre;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("genre");
__PACKAGE__->add_columns(
    "no", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 10
    },
    "genreid", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => 0,
	size => 3
    },
);
__PACKAGE__->set_primary_key("no", "genreid");

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index( name => 'idx_genreid_no', fields => ['genreid', 'no'] );
}

1;
