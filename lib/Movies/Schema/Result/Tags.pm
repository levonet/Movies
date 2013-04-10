package Movies::Schema::Result::Tags;

use strict;
use warnings;

use parent qw/Movies::Schema::Base::Result/;

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table("tags");
__PACKAGE__->add_columns(
    "genreid", {
	data_type => "INT",
	extra => { unsigned => 1 },
	is_nullable => 0,
	default_value => undef,
	size => 10,
	is_auto_increment => 1
    },
    "tag", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 150
    }
);
__PACKAGE__->set_primary_key("genreid");

#TODO index if need
#sub sqlt_deploy_hook {
#    my ($self, $sqlt_table) = @_;
#
#    $sqlt_table->add_index( name => 'idx_genreid', fields => ['genreid'] );
#}

1;
