package Movies::Controller::Edit;

use strict;

use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Edit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

#sub index :Path :Args(0) {
#    my ( $self, $c ) = @_;
#
#    $c->response->body('Matched Movies::Controller::Edit in Edit.');
#}

sub movies : Chained('/lang') PathPart('movies') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'movies.tt';
    $c->stash->{title} = $c->loc("Movies");
}

sub view_base : Chained('movies') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{current} = 'view';
    $c->stash->{no} = $id;

}

sub movies_edit_menu :Private {
    my ( $self, $c ) = @_;

    my $emenu = {
	general	=> { name => $c->loc("General"), hide => 0, current => 0 },
	desc	=> { name => $c->loc("Description"), hide => 0, current => 0 },
	cast	=> { name => $c->loc("Cast"), hide => 0, current => 0 },
	genre	=> { name => $c->loc("Genres"), hide => 0, current => 0 },
	path	=> { name => $c->loc("Files"), hide => 0, current => 0 },
    };

    $c->stash->{emenu_range} = [ 'general', 'desc', 'cast', 'genre', 'path' ];
    $c->stash->{emenu} = $emenu;
}

=head2 movie_create

=cut

sub movies_create : Chained('movies') PathPart('create') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'create';
    $c->stash->{template} = 'movie_edit.tt';
    $c->stash->{title} .= $c->loc(" :: Create");

    $c->forward('movies_edit_menu');

    $c->stash->{emenu}->{general}->{current} = 1;
    foreach my $key (keys %{$c->stash->{emenu}}) {
	$c->stash->{emenu}->{$key}->{hide} = 1;
    }

#    $c->stash->{user_granted} = $c->check_user_roles('Users');

    my $rs_data = {
	no		=> '00000000',
	date_add	=> '',
	orig_lang	=> '',
	orig_title	=> '',
	quality		=> 0,
	category	=> 'R',
	ryear		=> '',
	runtime		=> ''
    };

    $rs_data->{date_add} = sprintf("%04d-%02d-%02d",sub{($_[5]+1900,$_[4]+1,$_[3])}->(localtime));
    $c->stash->{rs_data} = $rs_data;
}

sub movies_create_upd : Chained('movies') PathPart('create_upd') Args(0) {
    my ( $self, $c ) = @_;

    if ($c->req->params->{runtime} =~ m/(\d+):(\d+):(\d+)/) {
	$c->req->params->{runtime} = ($1 * 60 * 60) + ($2 * 60) + $3;
    }

    my $rs = $c->model('DB::General')->create({
	date_add	=> $c->req->params->{date_add},
	orig_lang	=> $c->req->params->{orig_lang},
	orig_title	=> $c->req->params->{orig_title},
	quality		=> $c->req->params->{quality},
	category	=> $c->req->params->{category},
	ryear		=> $c->req->params->{ryear},
	runtime		=> $c->req->params->{runtime}
    });

    # zerofill fix
    $rs = $c->model('DB::General')->find($rs->id);

    $c->model('Search')->search_reindex($rs->no);

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $rs->no, 'edit', 'general') );
}

sub movies_delete : Chained('view_base') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

    my $dmenu = {
	all	=> { name => $c->loc("Delete"), hide => 1, current => 1 },
    };
    $c->stash->{dmenu_range} = [ 'all' ];
    $c->stash->{dmenu} = $dmenu;

    $c->stash->{current} = 'delete';
    $c->stash->{template} = 'movie_delete.tt';

    my $rs_general = $c->model('DB::General')->search({no => $c->stash->{no}});
    my $rs_desc = $c->model('DB::Description')->search({no => $c->stash->{no}});
    my $rs_cast = $c->model('DB::Cast')->search({no => $c->stash->{no}});
    my $rs_genre = $c->model('DB::Genre')->search({no => $c->stash->{no}});
    my $rs_path = $c->model('DB::Path')->search({no => $c->stash->{no}});
    my $rs_view = $c->model('DB::View')->search({no => $c->stash->{no}});

    my $row_general = $rs_general->single;

    $c->detach('not_found') unless (defined $row_general);

    $c->stash->{row_general} = $row_general;
    $c->stash->{title} .= $c->loc(" :: Delete [_1] - [_2] ([_3])", $c->stash->{no}, $row_general->orig_title, $row_general->ryear);

    $c->stash->{rc_general} = $rs_general->count;
    $c->stash->{rc_desc} = $rs_desc->count;
    $c->stash->{rc_cast} = $rs_cast->count;
    $c->stash->{rc_genre} = $rs_genre->count;
    $c->stash->{rc_path} = $rs_path->count;
    $c->stash->{rc_view} = $rs_view->count;

# poster
    my @posters;
    for (split(' ', $c->config->{posters_image_exts})) {
	my $file = $c->config->{upload_poster_path}.$c->stash->{no}.$_;
	if ( -f $file ) {
	    push(@posters, { file => $file, status => (stat($file))[7], name => $c->stash->{no}.$_ });
	}
    }
# storage
    my @files;
    my %tmp;
    foreach my $row ($rs_path->all) {
	my $file = $c->storage_filename({
		no		=> $c->stash->{no},
		storage		=> $row->storage,
		range		=> $row->range,
		file_name	=> $row->file_name
	    });
	if ( -f $file ) {
	    push(@files, { file => $file, status => (stat($file))[7], name => $row->file_name, storage => $row->storage });
	} else {
	    push(@files, { file => $file, status => $c->loc("not exists"), name => $row->file_name, storage => $row->storage });
	}
	my $dir = $file;
	$dir =~ s|(.*)/.*$|$1|;
	$tmp{$dir} = $file;
    }

    my @sdirs;
    foreach (keys %tmp) {
	if ( -d $_ ) {
	    push(@sdirs, { dir => $tmp{$_}, status => $c->loc("exists"), name => $_ });
	} else {
	    push(@sdirs, { dir => $tmp{$_}, status => $c->loc("not exists"), name => $_ });
	}
    }

    # Deleting
    if ($c->req->params->{confirm}) {
	if (ref $c->req->params->{delete_file} eq 'ARRAY') {
	    %tmp = map { $_ => 1 } @{$c->req->params->{delete_file}};
	} else {
	    %tmp = ( $c->req->params->{delete_file} => 1 );
	}
	foreach my $item (@posters, @files) {
	    if (exists $tmp{$item->{file}}) {
		if ($item->{status} =~ m/^\d+$/) {
$c->log->debug("XXXXXXXXXXXXXXXXXXX DELETE: ".$item->{name});
		    unless (unlink($item->{file})) {
			$item->{status} = $c->loc("Can't delete file '[_1]': [_2]", $item->{file}, $!);
		    } else {
			$item->{status} = $c->loc("deleted");
		    }
		}
	    }
	}
	if (ref $c->req->params->{delete_dirs} eq 'ARRAY') {
	    %tmp = map { $_ => 1 } @{$c->req->params->{delete_dirs}};
	} else {
	    %tmp = ( $c->req->params->{delete_dirs} => 1 );
	}
	
	foreach my $item (@sdirs) {
	    if (exists $tmp{$item->{dir}}) {
		unless ($c->storage_rmdirs($item->{dir})) {
		    $item->{status} = $c->loc("Can't delete directory");
		} else {
		    $item->{status} = $c->loc("deleted");
		}
	    }
	}

	$c->stash->{rv_view} = (defined $rs_view) ? $rs_view->delete : 0;
	$c->stash->{rv_path} = (defined $rs_path) ? $rs_path->delete : 0;
	$c->stash->{rv_genre} = (defined $rs_genre) ? $rs_genre->delete : 0;
	$c->stash->{rv_cast} = (defined $rs_cast) ? $rs_cast->delete : 0;
	$c->stash->{rv_desc} = (defined $rs_desc) ? $rs_desc->delete : 0;
	$c->stash->{rv_general} = (defined $rs_general) ? $rs_general->delete : 0;

	$c->model('Search')->search_indexdel($c->stash->{no});
    }

    $c->stash->{posters} = \@posters;
    $c->stash->{files} = \@files;
    $c->stash->{sdirs} = \@sdirs;
}

sub movies_edit : Chained('view_base') PathPart('edit') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'edit';
    $c->stash->{template} = 'movie_edit.tt';
    $c->stash->{title} .= $c->loc(" :: Edit [_1]", $c->stash->{no});

    $c->forward('movies_edit_menu');
}

sub movies_edit_general : Chained('movies_edit') PathPart('general') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{emenu}->{general}->{current} = 1;

    my $rs = $c->model('DB::General')->find($c->stash->{no});

    $c->detach('not_found') unless (defined $rs);

    $c->stash->{rs_data} = $rs;
    $c->stash->{title} .= $c->loc(" :: General - [_1] ([_2])", $rs->orig_title, $rs->ryear);

    $c->controller("Movies")->movies_set_poster($c);
}

sub movies_edit_general_upd : Chained('movies_edit') PathPart('general_upd') Args(0) {
    my ( $self, $c ) = @_;

#TODO проверяем полиси

    if ($c->req->params->{runtime} =~ m/(\d+):(\d+):(\d+)/) {
	$c->req->params->{runtime} = ($1 * 60 * 60) + ($2 * 60) + $3;
    }

    my $rs = $c->model('DB::General')->find($c->stash->{no});
    $rs->update({
	date_add	=> $c->req->params->{date_add},
	orig_lang	=> $c->req->params->{orig_lang},
	orig_title	=> $c->req->params->{orig_title},
	quality		=> $c->req->params->{quality},
	category	=> $c->req->params->{category},
	ryear		=> $c->req->params->{ryear},
	runtime		=> $c->req->params->{runtime}
    });

    $c->model('Search')->search_reindex($rs->no);

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general') );
}

sub movies_edit_poster_upd : Chained('movies_edit') PathPart('poster_upd') Args(0) {
    my ( $self, $c ) = @_;

#TODO проверяем полиси

    my $filename = undef;
    my $upload;

    unless ( $upload = $c->req->upload('imgfile') ) {
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general',
	    { status => $c->loc('Error') }) );
	return;
    }

    for (split(' ', $c->config->{posters_image_exts})) {
	if ( $upload->filename =~ m/$_$/ ) {
	    $filename = $c->config->{upload_poster_path}.$c->stash->{no}.$_;
	    last;
	}
    }

    unless ( defined $filename ) {
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general',
	    { status => $c->loc('file extension must be: [_1]', $c->config->{posters_image_exts}) }) );
	return;
    }
# TODO check size and scale

    unless ( $upload->link_to($filename) || $upload->copy_to($filename) ) {
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general',
	    { status => $! }) );
	return;
    }
    chmod(0644, $filename);

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general',
	{ status => $c->loc("upload image successful") }) );
}

sub movies_edit_poster_del : Chained('movies_edit') PathPart('poster_del') Args(0) {
    my ( $self, $c ) = @_;

    my $filename = undef;
    my $status = undef;

    for (split(' ', $c->config->{posters_image_exts})) {
	my $file = $c->config->{upload_poster_path}.$c->stash->{no}.$_;
	if ( -f $file ) {
	    $filename = $file;
	    last;
	}
    }
    if ( defined $filename ) {
	unless (unlink($filename)) {
	    $status = $c->loc("Can't delete file [_1]: [_2]", $filename, $!);
	} else {
	    $status = $c->loc("delete image successful");
	}
    } else {
	$status = $c->loc("file [_1] not found", $filename);
    }

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'general',
	{ status => $status }) );
}

sub movies_edit_desc : Chained('movies_edit') PathPart('desc') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{emenu}->{desc}->{current} = 1;

    my $rs_general = $c->model('DB::General')->find({no => $c->stash->{no}});

    $c->detach('not_found') unless (defined $rs_general);

    $c->stash->{title} .= $c->loc(" :: Description - [_1] ([_2])", $rs_general->orig_title, $rs_general->ryear);

    # list of descs
    unless ($c->req->params->{desc_lang}) {
	my $rs_list = $c->model('DB::Description')->titles_by_id($c->stash->{no});
	$c->stash->{rs_list} = $rs_list;
    } else {
    # edit desc by lang
	my $rs = $c->model('DB::Description')->find({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang}
	});
	$c->stash->{rs_data} = $rs;
	$c->stash->{title} .= $c->loc(" :: [_1]", $c->req->params->{desc_lang});
    }
}

sub movies_edit_desc_upd : Chained('movies_edit') PathPart('desc_upd') Args(0) {
    my ( $self, $c ) = @_;

#TODO проверяем полиси

    my $rs = $c->model('DB::Description')->find({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang}
	});
    if ($rs) {
	$rs->update({
	    title	=> $c->req->params->{title},
	    language	=> $c->req->params->{language},
	    production	=> $c->req->params->{production},
	    director	=> $c->req->params->{director},
	    country	=> $c->req->params->{country},
	    synopsis	=> $c->req->params->{synopsis}
	});
    } else {
	# Check lang in config
	if (exists $c->config->{'localization'}->{$c->req->params->{desc_lang}}) {
	    # Create
	    $c->model('DB::Description')->create({
		no		=> $c->stash->{no},
		desc_lang	=> $c->req->params->{desc_lang},
		title		=> $c->req->params->{title},
		language	=> $c->req->params->{language},
		production	=> $c->req->params->{production},
		director	=> $c->req->params->{director},
		country		=> $c->req->params->{country},
		synopsis	=> $c->req->params->{synopsis}
	    });
	} else {
	    # Error
	    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'desc',
		{status => $c->loc("Not standart language: [_1]. Check localization in config.", $c->req->params->{desc_lang}) }) );
	    return;
	}
    }
    $c->model('Search')->search_reindex($c->stash->{no});

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'desc', {desc_lang => $c->req->params->{desc_lang}}) );
}

sub movies_edit_desc_del : Chained('movies_edit') PathPart('desc_del') Args(0) {
    my ( $self, $c ) = @_;

# TODO relation
    $c->model('DB::Cast')->search({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang}
	})->delete_all;
    $c->model('DB::Description')->search({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang}
	})->delete_all;

    $c->model('Search')->search_reindex($c->stash->{no});

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'desc') );
}

sub movies_edit_cast : Chained('movies_edit') PathPart('cast') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{emenu}->{cast}->{current} = 1;

    my $rs_general = $c->model('DB::General')->find({no => $c->stash->{no}});

    $c->detach('not_found') unless (defined $rs_general);

    $c->stash->{title} .= $c->loc(" :: Cast - [_1] ([_2])", $rs_general->orig_title, $rs_general->ryear);

    my $rs = $c->model('DB::Description')->langs($c->stash->{no});

    my $desc_langs;
    push(@$desc_langs, {
	id	=> " ",
	name	=> $c->loc("select language")
    });
    foreach my $row ($rs->all) {
	push(@$desc_langs, {
	    id	 => $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'cast', {desc_lang => $row->desc_lang}),
	    name => $row->desc_lang." ".$c->enc($c->config->{'localization'}->{$row->desc_lang})
	});
    }
    $c->stash->{desc_langs} = $desc_langs;

    if ($c->req->params->{desc_lang}) {
	my $rs = $c->model('DB::Cast')->search({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang}
	});
	$c->stash->{rs_list} = $rs;
	$c->stash->{title} .= $c->loc(" :: [_1]", $c->req->params->{desc_lang});
    }
}

sub movies_edit_cast_add : Chained('movies_edit') PathPart('cast_add') Args(0) {
    my ( $self, $c ) = @_;

    if (exists $c->config->{'localization'}->{$c->req->params->{desc_lang}}) {
	# Add new actor
	$c->model('DB::Cast')->create({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang},
	    actor	=> $c->req->params->{actor},
	    role	=> $c->req->params->{role}
	});
    }

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'cast', { desc_lang => $c->req->params->{desc_lang} }) );
}

sub movies_edit_cast_del : Chained('movies_edit') PathPart('cast_del') Args(0) {
    my ( $self, $c ) = @_;

    $c->model('DB::Cast')->search({
	    no		=> $c->stash->{no},
	    desc_lang	=> $c->req->params->{desc_lang},
	    actor	=> $c->req->params->{actor},
	    role	=> $c->req->params->{role}
	})->delete;

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'cast', { desc_lang => $c->req->params->{desc_lang} }) );
}

sub movies_edit_genre : Chained('movies_edit') PathPart('genre') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{emenu}->{genre}->{current} = 1;

    my $rs_general = $c->model('DB::General')->find({no => $c->stash->{no}});

    $c->detach('not_found') unless (defined $rs_general);

    $c->stash->{title} .= $c->loc(" :: Genre - [_1] ([_2])", $rs_general->orig_title, $rs_general->ryear);

    my $rs = $c->model('DB::Genre')->search({no => $c->stash->{no}});
    $c->stash->{rs_list} = $rs;
}

sub movies_edit_genre_add : Chained('movies_edit') PathPart('genre_add') Args(0) {
    my ( $self, $c ) = @_;

    $c->model('DB::Genre')->create({
	no	=> $c->stash->{no},
	genreid	=> $c->req->params->{genreid}
    });

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'genre') );
}

sub movies_edit_genre_del : Chained('movies_edit') PathPart('genre_del') Args(0) {
    my ( $self, $c ) = @_;

    $c->model('DB::Genre')->search({
	    no		=> $c->stash->{no},
	    genreid	=> $c->req->params->{genreid}
	})->delete;

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'genre') );
}

sub movies_edit_path : Chained('movies_edit') PathPart('path') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{emenu}->{path}->{current} = 1;

    my $rs_general = $c->model('DB::General')->find({no => $c->stash->{no}});

    $c->detach('not_found') unless (defined $rs_general);

    $c->stash->{title} .= $c->loc(" :: Files - [_1] ([_2])", $rs_general->orig_title, $rs_general->ryear);

    my $rs = $c->model('DB::Path')->search({no => $c->stash->{no}});
    $c->stash->{rs_list} = $rs;

    unless (exists $c->req->params->{set}) {
	$c->req->params->{set} = 'manual';
    }
}

sub movies_edit_path_add : Chained('movies_edit') PathPart('path_add') Args(0) {
    my ( $self, $c ) = @_;

    my $status = undef;

    if ($c->req->params->{file_len} =~ m/(\d+):(\d+):(\d+)/) {
	$c->req->params->{file_len} = ($1 * 60 * 60) + ($2 * 60) + $3;
    }
    my $rs_data = {
	no		=> $c->stash->{no},
	range		=> $c->req->params->{range},
	note		=> $c->req->params->{note},
	storage		=> $c->req->params->{storage},
	file_name	=> $c->req->params->{file_name},
	file_size	=> $c->req->params->{file_size},
	file_len	=> $c->req->params->{file_len},
	audio		=> '',
	video		=> ''
    };

    if ($c->req->params->{set} eq 'upload') {

	my $upload;

	unless ( $upload = $c->req->upload('file') ) {
	    $status = $c->loc("Error: can't get upload request");
	}

	$rs_data->{file_name} = $upload->filename if (defined $upload);

	my $filename = $c->storage_filename($rs_data);

	unless (defined $status) {
	    unless ($c->storage_mkdirs($filename)) {
		$status = $c->loc("Error: can't create directory '[_1]'", $filename);
	    }
	}

	if (defined $upload && !defined $status) {
	    unless ( $upload->link_to($filename) || $upload->copy_to($filename) ) {
		$status = $c->loc("Error: [_1]", $!);
	    }
	    unless (defined $status) {
		chmod(0644, $filename) if -f $filename;
		$rs_data->{file_size} = (stat($filename))[7];
	    }
	}

	if (!defined $status && exists $c->req->params->{autoload} && $c->req->params->{autoload} eq 'yes') {

	    my $script_res = $c->exec_script('script_get_video', $filename);
	    if (defined $script_res) {
		$rs_data->{video} = $script_res;
	    } else {
		$rs_data->{video} = '';
		$status = $c->loc("Error in execute script '[_1]'", 'script_get_video');
	    }
	    $script_res = $c->exec_script('script_get_audio', $filename);
	    if (defined $script_res) {
		$rs_data->{audio} = $script_res;
	    } else {
		$rs_data->{audio} = '';
		$status = $c->loc("Error in execute script '[_1]'", 'script_get_audio');
	    }
	    $script_res = $c->exec_script('script_get_length', $filename);
	    if (defined $script_res) {
		$rs_data->{file_len} = $script_res;
	    } else {
		$rs_data->{file_len} = '';
		$status = $c->loc("Error in execute script '[_1]'", 'script_get_length');
	    }
	}
    }

    if (!defined $status && $rs_data->{file_name} ne '') {

	$c->model('DB::Path')->create($rs_data);

	# Refreash runtime
	$c->model('DB::General')->find($c->stash->{no})->update({
		    runtime	=> $c->model('DB::Path')->runtime($c->stash->{no})
	    });

	$c->model('Search')->search_reindex($c->stash->{no});
    } else {
	$status .= '<br>';
	$status .= $c->loc("Database not updated.");
    }

    my $params = {
	set	 => $c->req->params->{set} || 'manual',
	autoload => $c->req->params->{autoload} eq 'yes' ? 1 : 0,
	storage	 => $c->req->params->{storage}
    };
    $params->{status} = $status if defined $status;

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'path', $params) );
}

sub movies_edit_path_del : Chained('movies_edit') PathPart('path_del') Args(0) {
    my ( $self, $c ) = @_;

    my $params = {};
    my $status = undef;

    my $rs_data = $c->model('DB::Path')->search({no => $c->stash->{no}, range => $c->req->params->{range}})->single;

    if (exists $c->req->params->{all} && defined $rs_data) {
	my $filename = $c->storage_filename({
		no		=> $c->stash->{no},
		storage		=> $rs_data->storage,
		range		=> $rs_data->range,
		file_name	=> $rs_data->file_name
	    });
	if ( -f $filename ) {
	    unless (unlink($filename)) {
		$status = $c->loc("Can't delete file [_1]: [_2]", $filename, $!);
	    }
	} else {
	    $status = $c->loc("file [_1] not found", $filename);
	}
	if ($c->req->params->{range} == 1) {
	    $c->storage_rmdirs($filename);
	}
    }
    if (!defined $status && defined $rs_data) {
	$rs_data->delete;
    }

    $params->{status} = $status if defined $status;

    # Refreash runtime
    $c->model('DB::General')->find($c->stash->{no})->update({
	    runtime	=> $c->model('DB::Path')->runtime($c->stash->{no})
	});

    $c->model('Search')->search_reindex($c->stash->{no});

    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'movies', $c->stash->{no}, 'edit', 'path', $params) );
}

########  PRIVATE  ########################################################

sub begin : Private {
    my ( $self, $c ) = @_;

    my $rs = $c->model('DB::Path')->state;
    if ($rs) {
	$c->stash->{files_sz} = $rs->get_column('files_sz');
	$c->stash->{files_cnt} = $rs->get_column('files_cnt');
    } else {
	$c->stash->{files_sz} = 0;
	$c->stash->{files_cnt} = 0;
    }
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
