package Movies::Schema;
use Moose;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces( default_resultset_class => '+Movies::Schema::Base::ResultSet' );
#__PACKAGE__->load_namespaces;

=head1 NAME

Movies::Schema

=head1 METHODS

=head2 create_initial_data

Creates initial set of data in the database which is necessary to run Movies.

=cut

sub create_initial_data {
    my ($schema, $config) = @_;

    my $file = __PACKAGE__ . ".pm";
    $file =~ s{::}{/}g;
    my $path = $INC{$file};
    $path =~ s{Schema\.pm$}{I18N};

    require Locale::Maketext::Simple;
    Locale::Maketext::Simple->import(
        Decode => 1,
        Class  => 'Movies',
        Path   => $path,
    );
    my $lang = $config->{'default_lang'} || 'en';
    $lang =~ s/\..*$//;
    loc_lang($lang);

    my $default_user = $ENV{USER} || 'admin';

    print "Creating initial data\n";

    my $tm = sprintf("%04d-%02d-%02d %02d:%02d:%02d",sub{($_[5]+1900,$_[4]+1,$_[3],$_[2],$_[1],$_[0])}->(localtime));
    my @users = $schema->populate(
	'User', [
	    [ qw/ id login password email_address name active login_time login_host / ],
	    [ 1, 'anonymous', '', 'root@localhost', loc('Anonymous'), 1, $tm, '' ],
	    [ 2, 'admin', 'admin', 'root@localhost', loc('Administrator'), 1, $tm, '' ],
#           [ 2, $custom_values->{admin_username}, $custom_values->{admin_password}, $custom_values->{admin_email}, $custom_values->{admin_fullname}, 1, 'curdate()', '' ]
	]
    );

    my @roles = $schema->populate(
	'Role', [
	    [ qw/ id role / ],
	    [ 1, 'Anonymous' ],
	    [ 2, 'Admins' ],
	    [ 3, 'Users' ]
	]
    );

    my @user_roles = $schema->populate(
	'UserRole', [
	    [ qw/ user_id role_id/ ],
	    [ $users[0]->id, $roles[0]->id ],
	    [ $users[1]->id, $roles[0]->id ],
	    [ $users[1]->id, $roles[1]->id ],
	    [ $users[1]->id, $roles[2]->id ]
	]
    );

    print "Set AUTO_INCREMENT=10000 in main table\n";

    my $row = $schema->resultset('General')->create({
	    no		=> '0000009999',
	    date_add	=> '0000-00-00',
	    orig_lang	=> 'zz',
	    orig_title	=> 'Z',
	    quality	=> 0,
	    category	=> '',
	    ryear	=> '0000'
	});
    die "Error: can't INSERT into General table." unless ($row);

    $row->delete;

#    $schema->resultset('Page')->update( { version         => 1 } );
#    $schema->resultset('Page')->update( { content_version => 1 } );
#    $schema->resultset('PageVersion')->update( { content_version_first => 1 } );
#    $schema->resultset('PageVersion')->update( { content_version_last  => 1 } );

    print "Success!\n";
}

1;
