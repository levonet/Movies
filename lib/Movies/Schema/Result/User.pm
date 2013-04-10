package Movies::Schema::Result::User;

use strict;
use warnings;

use Digest::SHA1;

use parent qw/Movies::Schema::Base::Result/;

#__PACKAGE__->load_components(
#    qw/DateTime::Epoch TimeStamp EncodedColumn UTF8Columns Core/);

__PACKAGE__->load_components(qw/InflateColumn::DateTime EncodedColumn Core/);
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
    "id", {
	data_type => "INT",
	is_nullable => 0,
	default_value => undef,
	size => 11,
	is_auto_increment => 1
    },
    "login", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 32
    },
    "password", {
	data_type => "CHAR",
	is_nullable => 0,
	size => 41,
	encode_column => 1,
	encode_class => 'Digest',
	encode_args => { algorithm => 'SHA-1', format => 'hex' },
	encode_check_method => 'check_password',
    },
    "email_address", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 32
    },
    "name", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 100
    },
    "active", {
	data_type => "INT",
	is_nullable => 0,
	default_value => 1,
	size => 11
    },
    "login_time", {
	data_type => "DATETIME",
	is_nullable => 0,
	default_value => "0000-00-00 00:00:00",
	size => 19,
    },
    "login_host", {
	data_type => "VARCHAR",
	is_nullable => 0,
	default_value => "",
	size => 60
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( login => [qw/login/], );
#__PACKAGE__->utf8_columns(qw/login name/); # deprecated module UTF8Columns

__PACKAGE__->has_many(map_user_roles => 'Movies::Schema::Result::UserRole', 'user_id');
__PACKAGE__->many_to_many(roles => 'map_user_roles', 'role');

=head1 METHODS

=head2 valid_pass <password>

Check password against database.

=cut

sub valid_pass {
    my ( $self, $pass ) = @_;
    return $self->check_password($pass);
}

sub hashed {
    my ( $self, $secret ) = @_;
    return Digest::SHA1::sha1_hex( $self->id . $secret );
}

1;
