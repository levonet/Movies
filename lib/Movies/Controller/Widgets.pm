package Movies::Controller::Widgets;

use strict;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Widgets - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 query_list

=cut

sub query_list : Chained('/lang') PathPart('query_list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current_view} = 'TTEmpty';
    $c->stash->{template} = 'query_list.tt';
    my $rs_list;

    if ($c->req->params->{qlst} eq 'orig_lang') {
	$rs_list = $c->model('DB::General')->ql_orig_lang;
    } elsif ($c->req->params->{qlst} eq 'desc_lang') {
	$rs_list = $c->model('DB::Description')->ql_desc_lang;
    } elsif ($c->req->params->{qlst} eq 'language') {
	$rs_list = $c->model('DB::Description')->ql_language;
    } elsif ($c->req->params->{qlst} eq 'production') {
	$rs_list = $c->model('DB::Description')->ql_production;
    } elsif ($c->req->params->{qlst} eq 'director') {
	$rs_list = $c->model('DB::Description')->ql_director;
    } elsif ($c->req->params->{qlst} eq 'country') {
	$rs_list = $c->model('DB::Description')->ql_country;
    } elsif ($c->req->params->{qlst} eq 'actor') {
	$rs_list = $c->model('DB::Cast')->ql_actor;
    }

    $c->stash->{rs_list} = $rs_list;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
