package Movies::Controller::Admin;

use strict;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub admin : Chained('/lang') PathPart('admin') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{title} .= $c->loc(" :: Administration");
    $c->stash->{template} = 'admin/admin.tt';
}

sub index : Chained('admin') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'admin';

    # Hook
    if (exists $c->req->params->{confirm}) {
	my $status = undef;
	my $params = {};

	if ($c->req->params->{confirm} eq 'reindex') {
	    $c->model('Search')->rebuild_indexes;
	    $status = $c->loc("Search indexes rebuilded successfully.");
	} elsif ($c->req->params->{confirm} eq 'upd_db') {
	    $c->forward('admin_update_db');
	    $params->{db_path} = $c->req->params->{db_path} if exists $c->req->params->{db_path};
	    $params->{db_general} = $c->req->params->{db_general} if exists $c->req->params->{db_general};
	    $params->{show_fnf} = 1 if exists $c->req->params->{show_fnf};
	}

	$params->{status} = $status if defined $status;
	$params->{status} = $c->stash->{status} if exists $c->stash->{status};
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'admin', $params) );
	return;
    }

    $c->stash->{files_not_found} = $c->flash->{files_not_found} if exists $c->req->params->{show_fnf};
}

sub admin_redirect : Chained('admin') PathPart('redirect') Args(1) {
    my ( $self, $c, $proc ) = @_;

    $c->stash->{current} = 'admin';
    $c->stash->{template} = 'pleasewait.tt';

    if ($proc eq 'reindex') {
	$c->stash->{message} = $c->loc("Rebuilding search indexes.");
    } elsif ($proc eq 'upd_db') {
	$c->stash->{message} = $c->loc("Updating database from storage.");
    }

    my $params = {};
    foreach my $param (keys %{$c->req->params}) {
	$params->{$param} = $c->req->params->{$param} unless $param eq 'submit';
    }
    $params->{confirm} = $proc;

    $c->stash->{uri_redir} = $c->uri_for('/', $c->stash->{lang}, 'admin', $params);

}

sub admin_update_db : Private {
    my ( $self, $c ) = @_;

    my %path_fields = ();
    if (exists $c->req->params->{db_path}) {
	if (ref $c->req->params->{db_path} eq 'ARRAY') {
	    %path_fields = map { $_ => 0 } @{$c->req->params->{db_path}};
	} else {
	    %path_fields = ( $c->req->params->{db_path} => 0 );
	}
    }

    my $runtime_upd = ( exists $c->req->params->{db_general} && $c->req->params->{db_general} eq 'runtime' ) ? 0 : undef;
    my $path_upd = scalar(keys %path_fields);

    if ( $path_upd || defined $runtime_upd ) {

	my $rs = $c->model('DB::General')->search(undef, {select => [ 'me.no' ]});
	foreach my $row ($rs->all) {
	    if ($path_upd) {
		my $script_res;
		foreach my $row_path ( $row->paths->all) {
		    my $filename = $c->storage_filename({
			    no		=> $row->no,
			    storage	=> $row_path->storage,
			    range	=> $row_path->range,
			    file_name	=> $row_path->file_name
			});
		    unless (-f $filename) {
			push(@{$c->flash->{files_not_found}}, $filename);
			next;
		    }

		    my $fs_path = {};
		    if (exists $path_fields{file_size}) {
			$fs_path->{file_size} = (stat($filename))[7];
			$path_fields{file_size}++;
		    }
		    if (exists $path_fields{file_len}) {
			$script_res = $c->exec_script('script_get_length', $filename);
			if (defined $script_res) {
			    $fs_path->{file_len} = $script_res;
			    $path_fields{file_len}++;
			}
		    }
		    if (exists $path_fields{audio}) {
			$script_res = $c->exec_script('script_get_audio', $filename);
			if (defined $script_res) {
			    $fs_path->{audio} = $script_res;
			    $path_fields{audio}++;
			}
		    }
		    if (exists $path_fields{video}) {
			$script_res = $c->exec_script('script_get_video', $filename);
			if (defined $script_res) {
			    $fs_path->{video} = $script_res;
			    $path_fields{video}++;
			}
		    }
		    $row_path->update($fs_path) if scalar(keys %{$fs_path});
		}
	    }
	    if (defined $runtime_upd) {
		# Refreash runtime
		$runtime_upd++ if $row->update({ runtime => $c->model('DB::Path')->runtime($row->no) });
	    }
	}
	$c->stash->{status} = $c->loc("Total processing [_1]", $rs->count);
	$c->stash->{status} .= '<br>';
	foreach (qw/file_size file_len audio video/) {
	    if (exists $path_fields{$_}) {
		$c->stash->{status} .= $c->loc("Path.[_1] [_2] updated", $_, $path_fields{$_});
		$c->stash->{status} .= '<br>';
	    }
	}
	$c->stash->{status} .= $c->loc("General.[_1] [_2] updated", 'runtime', $runtime_upd) if defined $runtime_upd;
    } else {
	$c->stash->{status} = $c->loc("Nothing to update.");
    }
}

sub admin_users : Chained('admin') PathPart('users') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{title} .= $c->loc(" :: Users");
    $c->stash->{current} = 'admin_users';
    $c->stash->{template} = 'admin/users.tt';

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs = $c->model('DB::User')->users_by_id($rows, $page);
    $c->stash->{user_list} = $rs;

    $c->stash->{pager} = $rs->pager;
    $c->stash->{displaypages} = $c->config->{displaypages} || 5;

}

sub admin_roles : Chained('admin') PathPart('roles') Args(1) {
    my ( $self, $c, $uid ) = @_;

    $c->stash->{title} .= $c->loc(" :: Roles");
    $c->stash->{current} = 'admin_roles';
    $c->stash->{template} = 'admin/roles.tt';
#TODO

}

sub admin_user_create : Chained('admin') PathPart('user_create') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'admin_user_create';
    $c->controller('Auth')->auth_signup($c);

# Глюк с каптчей, не обновляется !!!!!!!

}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
