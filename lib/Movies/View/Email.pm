package Movies::View::Email;

use strict;
use base 'Catalyst::View::Email::Template';

__PACKAGE__->config(
    stash_key       => 'email',
    template_prefix => 'mail',
    sender          => {
        mailer          => 'SMTP',
    },
    default         => {
        content_type    => 'text/plain',
        charset         => 'utf-8',
        view            => 'TTEmpty',
    },
);

=head1 NAME

Movies::View::Email - Templated Email View for Movies

=head1 DESCRIPTION

View for sending template-generated email from Movies. 

=head1 AUTHOR

A clever guy

=head1 SEE ALSO

L<Movies>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
