use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Movies' }
BEGIN { use_ok 'Movies::Controller::Movies' }

ok( request('/en/movies')->is_success, 'Request should succeed' );


