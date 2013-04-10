use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Movies' }
BEGIN { use_ok 'Movies::Controller::Admin' }

ok( request('/admin')->is_success, 'Request should succeed' );


