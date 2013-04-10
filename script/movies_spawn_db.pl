#!/usr/bin/perl

BEGIN { $ENV{CATALYST_DEBUG} = 0 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Movies::Schema;
use Config::JFDI;
#use Getopt::Long;

my ( $dsn, $dbuser, $dbpass );

my $jfdi = Config::JFDI->new(name => "Movies");
my $config = $jfdi->get;

eval {
    unless ($dsn) {
        if (ref $config->{'Model::DB'}->{'connect_info'}) {
            ($dsn, $dbuser, $dbpass) =
                @{ $config->{'Model::DB'}->{'connect_info'} };
        } else {
            $dsn = $config->{'Model::DB'}->{'connect_info'};
        }
    };
};
if($@){
    die "Your DSN line in movies.conf doesn't look like a valid DSN.".
      "  Add one, or pass it on the command line.";
}
die "No valid Data Source Name (DSN). \n" unless $dsn;
$dsn =~ s/__HOME__/$FindBin::Bin\/\.\./g;

my $schema = Movies::Schema->connect($dsn, $dbuser, $dbpass)
    or die "Failed to connect to database";

# Check if database is already deployed by
# examining if the table Person exists and has a record.
eval {  $schema->resultset('Movies::Schema::Result::Users')->count };
if (!$@ ) {
    die "You have already deployed your database\n";
}

print <<"EOF";

Creating a new movies ...

  dsn:            $dsn
  admin username: admin
  admin password: admin
  guest username: anonymous
  home		: __HOME__

EOF

print "Deploying schema to $dsn\n";
$schema->deploy;

#$schema->create_initial_data($config, \%opts);
$schema->create_initial_data($config);

#my $users = $schema->resultset('Users')->search({ username => 'admin' });
#my $user = $users->first();
#$user->password('admin');
#$user->update;
#
#$user = $schema->resultset('Users')->single({ username => 'guest' });
#print ref $user, "\n";
#print $user->password, "\n";
#$user->password('');
#$user->update;

#foreach my $user (@users) {
#    $user->password('admin');
#    $user->update;
#}
