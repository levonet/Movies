use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Movies' }
BEGIN { use_ok 'Movies::Controller::Auth' }

ok( request('/auth')->is_success, 'Request should succeed' );


