package Movies::Controller::Root;

use utf8;

use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Movies::Controller::Root - Root Controller for Movies

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

#    my $menu = {
#	new	=> { name => $c->loc("New"), hide => 0, current => 0 },
#	ctg	=> { name => $c->loc("By genre"), hide => 0, current => 0 },
#	alphabet=> { name => $c->loc("By alphabet"), hide => 0, current => 0 },
#	hr_edit	=> undef,
#	list	=> { name => $c->loc("Full list"), hide => 0, current => 0 },
#	create	=> { name => $c->loc("Add movie"), hide => 0, current => 0 },
#	edit	=> { name => $c->loc("Edit"), hide => 0, current => 0 },
#	delete	=> { name => $c->loc("Delete"), hide => 0, current => 0 },
#	hr_adm	=> undef,
#	admin	=> { name => $c->loc("Administration"), hide => 0, current => 0 },
#	test	=> { name => $c->loc("Test"), hide => 0, current => 0 },
#    };
#
#    $c->stash->{menu} = $menu;

    $c->stash->{'uri_path'} = '/'.$c->req->path;
}

sub root : Chained('index') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->res->redirect( $c->uri_for_default );
}

sub lang : Chained('index') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $lng) = @_;

    # Set language
    $c->stash->{lang} = $c->check_lang($lng);
    $c->languages([ $c->stash->{lang} ]);
}

sub language : Chained('lang') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->res->redirect( $c->uri_for_default );
}

sub not_found : Private {
    my ( $self, $c ) = @_;

    $c->res->status(404);
    $c->stash->{title} = $c->loc("404 Not Found");
    $c->stash->{message} = $c->loc(
        "The requested URL [_1] was not found.",
        '<span class="message_detail">' . $c->req->uri->clone . '</span>'
    );
    $c->stash->{template} = 'message.tt';
}

# example
sub access_denied : Private {
    my ( $self, $c ) = @_;

    $c->res->status(404);
    $c->stash->{title} = $c->loc("Permissiot denied");
    $c->stash->{message} = $c->loc("You are not authorized to access this page.");
    $c->stash->{template} = 'message.tt';
}

sub default : Private {
    my ( $self, $c ) = @_;

    # Set language
    $c->stash->{lang} = $c->check_lang();
    $c->languages([ $c->stash->{lang} ]);

    $c->forward('not_found');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
