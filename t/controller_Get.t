use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Movies' }
BEGIN { use_ok 'Movies::Controller::Get' }

ok( request('/get')->is_success, 'Request should succeed' );


