package Movies::Controller::Get;

use strict;

use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Get - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(4) {
    my ( $self, $c, $url_t, $no, $range, $file) = @_;

    my $rs = $c->model('DB::Path')->get($no, $range)->single;
    $rs->update({ counter => $rs->counter + 1 });

    unless (exists $c->config->{storages}->{$rs->storage}->{$url_t}) {
	$c->stash->{title} = $c->loc("Error");
	$c->stash->{message} = $c->loc(
	    'Storage or requested file [_1] was not found in database.',
	    '<span class="message_detail">' . $file . '</span>');
	$c->stash->{template} = 'message.tt';
	return;
    }
    my $url = $c->config->{storages}->{$rs->storage}->{$url_t};
    $url =~ s/\%n/$no/g;
    $url =~ s/\%r/$range/g;
    $url =~ s/\%s/{$rs->storage}/eg;
    $url =~ s/\%f/{$rs->file_name}/eg;

    $c->res->redirect( $url );
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
