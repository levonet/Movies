use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Movies' }
BEGIN { use_ok 'Movies::Controller::Edit' }

ok( request('/edit')->is_success, 'Request should succeed' );


