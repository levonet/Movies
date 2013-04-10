package Movies::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
	TEMPLATE_EXTENSION => '.tt',
	INCLUDE_PATH => [
	    Movies->path_to('root','base'),
	],
	WRAPPER => 'wrapper.tt',
    );

=head1 NAME

Movies::View::TT - TT View for Movies

=head1 DESCRIPTION

TT View for Movies. 

=head1 SEE ALSO

L<Movies>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
