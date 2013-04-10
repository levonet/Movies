package Movies::Controller::Movies;

use strict;

use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Movies - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub movies : Chained('/lang') PathPart('movies') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'movies.tt';
    $c->stash->{title} = $c->loc("Movies");
}

sub index : Chained('movies') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{query} = '0d02';
    $c->forward('movies_new');
}

########  LISTS  ##########################################################

sub movies_list :Private {
    my ( $self, $c ) = @_;

    my $rs_list = $c->stash->{rs_list};
    $c->stash->{pager} = $rs_list->pager;
    $c->stash->{displaypages} = $c->config->{displaypages} || 5;

    my $loc_movies = {};

    foreach my $row ($rs_list->all) {
	my $rs = $c->model('DB::Description')->titles_by_id($row->no);
	my $rs_lang = $rs->find({ desc_lang => $c->stash->{lang} });
	if (defined $rs_lang) {
	    $loc_movies->{$row->no}->{lang} = $rs_lang->desc_lang;
	    $loc_movies->{$row->no}->{title} = $rs_lang->title;
	    if ($row->orig_lang eq $rs_lang->desc_lang) {
		$loc_movies->{$row->no}->{type} = 0;
	    } else {
		$loc_movies->{$row->no}->{type} = 1;
	    }
	} else {
	    my $rs_cfglang = $rs->find({ desc_lang => $c->config->{default_lang} });
	    if (defined $rs_cfglang) {
		$loc_movies->{$row->no} = {
		    type => 1,
		    lang => $rs_cfglang->desc_lang,
		    title => $rs_cfglang->title
		};
	    } else {
		$loc_movies->{$row->no}->{type} = -1;
	    }
	}
    }
    $c->stash->{loc_movies} = $loc_movies;
}

sub movies_new : Chained('movies') PathPart('new') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'new';
    $c->stash->{title} .= $c->loc(" :: New & Upcoming movies");

    $c->stash->{q_select} = {
	'0d02' => $c->loc('2 days'),
	'0d03' => $c->loc('3 days'),
	'0d04' => $c->loc('4 days'),
	'0d05' => $c->loc('5 days'),
	'0d06' => $c->loc('6 days'),
	'1w07' => $c->loc('This Week'),
	'2m01' => $c->loc('One month'),
	'2m02' => $c->loc('Two month')
    };
    unless (exists $c->stash->{query}) {
	$c->stash->{query} = (exists $c->req->params->{__q})
	    ? $c->req->params->{__q} : '0d02';
    }
    my $cond = {};
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 2 day' ] } if $c->stash->{query} eq '0d02';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 3 day' ] } if $c->stash->{query} eq '0d03';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 4 day' ] } if $c->stash->{query} eq '0d04';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 5 day' ] } if $c->stash->{query} eq '0d05';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 6 day' ] } if $c->stash->{query} eq '0d06';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 7 day' ] } if $c->stash->{query} eq '1w07';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 1 month' ] } if $c->stash->{query} eq '2m01';
    $$cond{'me.date_add'} = { '>=' => \[ 'curdate()-interval 2 month' ] } if $c->stash->{query} eq '2m02';
    my $rows = $c->config->{itemsperpage} || 25;

    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_new($cond, $rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->forward('movies_list');
}

sub movies_ctg : Chained('movies') PathPart('ctg') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'ctg';
    $c->stash->{title} .= $c->loc(" :: By genre");

    $c->stash->{category} = [ $c->model('DB::Genre')->group_category->all ];

}

sub movies_ctg_by : Chained('movies') PathPart('ctg') Args(1) {
    my ( $self, $c, $cur_genre ) = @_;

    $c->stash->{current} = 'ctg';
    $c->stash->{title} .= $c->loc(" :: By genre");
    $c->stash->{title} .= $c->loc(" :: [_1]", $c->find_by_id($c->genres, $cur_genre));

    $c->stash->{cur_genre} = $cur_genre;
    $c->stash->{category} = [ $c->model('DB::Genre')->group_category->all ];

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_ctg_by({ 'genres.genreid' => $cur_genre }, $rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->forward('movies_list');
}

sub movies_alphabet_head :Private {
    my ( $self, $c ) = @_;

    my $alphabet_conf_lang =
	(exists $c->config->{'charset'}->{'alias'}->{$c->config->{'default_lang'}})
	    ? $c->config->{'charset'}->{'alias'}->{$c->config->{'default_lang'}}
	    : $c->config->{'default_lang'};
    my $alphabet_desc_lang =
	(exists $c->config->{'charset'}->{'alias'}->{$c->stash->{lang}})
	    ? $c->config->{'charset'}->{'alias'}->{$c->stash->{lang}}
	    : $c->stash->{lang};

#    $c->log->debug("alphabet{conf} = ".$alphabet_conf_lang);
#    $c->log->debug("alphabet{desc} = ".$alphabet_desc_lang);
    $c->stash->{alphabet_conf_lang} = $alphabet_conf_lang;
    $c->stash->{alphabet_desc_lang} = $alphabet_desc_lang;

    my $rs_desc = $c->model('DB::Description')->alphabet_group;
    my $rs_gen = $c->model('DB::General')->alphabet_group;
    my $letter = {};

    foreach my $row ($rs_desc->all) { $letter->{$c->enc($row->get_column('letter'))} = $c->enc($row->get_column('letter')); }
    foreach my $row ($rs_gen->all) { $letter->{$c->enc($row->get_column('letter'))} = $c->enc($row->get_column('letter')); }
    foreach (0..9) { if (exists $letter->{$_}) { $letter->{'0-9'} = '0-9'; last; } }

    $c->stash->{letter_hash} = $letter;
    $c->stash->{letter} = sub {
	my ( $self, $key ) = @_;
	return $self->stash->{letter_hash}->{$key};
    };

    $c->stash->{alphabet_main} = [ '0-9' ];
    if (exists $c->config->{'charset'}->{$alphabet_conf_lang}) {
	my $ab = $c->config->{'charset'}->{$alphabet_conf_lang};
	$ab =~ s/\s+/ /g;
	push(@{$c->stash->{alphabet_main}}, @{[ split(/ /, $ab) ]});
    } else {
	$alphabet_conf_lang = 'en';
	push(@{$c->stash->{alphabet_main}}, @{[ 'A'..'Z' ]});
    }
    push(@{$c->stash->{alphabet_main}}, $c->loc("Another"));
    $letter->{$c->loc("Another")} = $c->loc("Another");
    if ($alphabet_conf_lang ne $alphabet_desc_lang &&
	exists $c->config->{'charset'}->{$alphabet_desc_lang}) {
	my $ab = $c->config->{'charset'}->{$alphabet_desc_lang};
	$ab =~ s/\s+/ /g;
	$c->stash->{alphabet_second} = [ split(/ /, $ab) ];
    }
}

sub movies_alphabet : Chained('movies') PathPart('alphabet') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'alphabet';
    $c->stash->{title} .= $c->loc(" :: By name");

    $c->forward('movies_alphabet_head');
}

sub movies_alphabet_by : Chained('movies') PathPart('alphabet') Args(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash->{current} = 'alphabet';
    $c->stash->{title} .= $c->loc(" :: By name");

    $c->stash->{cur_letter} = $c->enc($id);

    $c->forward('movies_alphabet_head');

    my $cond = {};
    if ($id eq '0-9') {
	$$cond{-or} = [
	    'descriptions.title' => { -rlike => '^[0-9]' },
	    'me.orig_title'	 => { -rlike => '^[0-9]' } ];
    } elsif ($c->enc($id) eq $c->loc("Another")) {
#	my $str = $c->enc(join('',@{$c->stash->{alphabet_main}}));
#	$str .= $c->enc(join('',@{$c->stash->{alphabet_second}})) if exists $c->stash->{alphabet_second};
	my $str = join('',@{$c->stash->{alphabet_main}});
	$str .= join('',@{$c->stash->{alphabet_second}}) if exists $c->stash->{alphabet_second};
	my $another = $c->loc("Another");
	$str =~ s/$another//g;
#$c->log->debug("alphabet{".$c->enc($id)."} = [".$str."]");
	$$cond{-and} = [
	    'descriptions.title' => { -not_rlike => '^['.$str.']' },
	    'me.orig_title'	 => { -not_rlike => '^['.$str.']' } ];
	push(@{$$cond{-and}}, {'descriptions.desc_lang'	=> $c->stash->{lang}})
	    if $c->stash->{alphabet_conf_lang} eq $c->stash->{alphabet_desc_lang};
    } else {
	$$cond{-or} = [
	    'descriptions.title' => { -like => $id.'%' },
	    'me.orig_title'	 => { -like => $id.'%' } ];
    }

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_alphabet_by($cond, $rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->forward('movies_list');
}

sub movies_release : Chained('movies') PathPart('release') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'release';
    $c->stash->{title} .= $c->loc(" :: By release year");

    $c->stash->{rel_years} = $c->model('DB::General')->group_years;

}

sub movies_release_by : Chained('movies') PathPart('release') Args(1) {
    my ( $self, $c, $cur_year ) = @_;

    $c->stash->{current} = 'release';
    $c->stash->{title} .= $c->loc(" :: By release year");
    $c->stash->{title} .= $c->loc(" :: [_1]", $cur_year);

    $c->stash->{cur_year} = $cur_year;
    $c->stash->{rel_years} = $c->model('DB::General')->group_years;

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_release_by({ 'me.ryear' => $cur_year }, $rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->forward('movies_list');
}

sub movies_search : Chained('movies') PathPart('search') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'search';

    unless (exists $c->req->params->{q}) {
	$c->stash->{title} .= $c->loc(" :: Search");
	return;
    }

    my $str = $c->req->params->{q};
    $str =~ s/_/ /g;

    my @words = ();
    push(@words, uc($+)) while $str =~ m/(\w+)/gx;

    $c->stash->{title} .= $c->loc(" :: Search");
    $c->stash->{title} .= $c->loc(" :: [_1]", lc(join('+', @words)));

    unless (scalar(@words)) {
	$c->stash->{status} = $c->loc("Wrong query. Please verify your request.");
	return;
    }

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('Search')->search_process(\@words, $rows, $page);

    $c->stash->{rs_list} = $rs_list;

    if (defined $rs_list) {
	$c->forward('movies_list');
    } else {
	$c->stash->{status} =
		$c->loc("No results for \"[_1]\". Please check your spelling, or try a different keyword.",
		lc(join('+', @words)));
    }
}

sub movies_actor : Chained('movies') PathPart('actor') Args(1) {
    my ( $self, $c, $actor_name ) = @_;

    $c->stash->{current} = 'actor';
    $c->stash->{title} .= $c->loc(" :: [_1] :: Filmography", $c->enc($actor_name));

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_actor_by({ 'actors.actor' => $actor_name }, $rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->forward('movies_list');
}

sub movies_list_full : Chained('movies') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{current} = 'list';
    $c->stash->{title} .= $c->loc(" :: Full list");

#TODO roles

    my $rows = $c->config->{itemsperpage} || 25;
    my $page = $c->req->params->{page} || 1;

    my $rs_list = $c->model('DB::General')->list_full($rows, $page);

    $c->stash->{rs_list} = $rs_list;
    $c->stash->{pager} = $rs_list->pager;
    $c->stash->{displaypages} = $c->config->{displaypages} || 7;

}

########  VIEW  ###########################################################

sub view_base : Chained('movies') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{current} = 'view';
    $c->stash->{no} = $id;

}

#
#TODO: Показать список описаний в собственных локалях
# sub view_descs

sub view_movie_descs : Chained('view_base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'view_descs.tt';

    my $rs_general = $c->model('DB::General')->find({no => $c->stash->{no}});

    $c->detach('not_found') unless (defined $rs_general);

    $c->stash->{title} .= $c->loc(" :: [_1] ([_2])", $c->enc($rs_general->orig_title), $rs_general->ryear);
    $c->forward('movies_set_poster');

    my $rs_list = $c->model('DB::Description')->titles_by_id($c->stash->{no});

    $c->stash->{general} = $rs_general;
    $c->stash->{rs_list} = $rs_list;
}

sub view_movie : Chained('view_base') PathPart('') Args(1) {
    my ( $self, $c, $desc_lang ) = @_;

    $c->stash->{template} = 'view.tt';
    $c->stash->{desc_lang} = $desc_lang;

    $c->stash->{user_granted} = $c->check_user_roles('Users');

    my $rs = $c->model('DB::General')->view($c->stash->{no}, $desc_lang)->single;

    $c->detach('not_found') unless (defined $rs);

    $rs->update({ viewed => $rs->viewed + 1 });
    $c->stash->{desc} = $rs;

    if ($c->user_exists) {
	if (defined $c->req->params->{set_view}) {
	    if ($c->req->params->{set_view} eq 'on') {
		$c->model('DB::View')->create({
			no	=> $c->stash->{no},
			user_id	=> $c->user->id
		    });
		$c->stash->{view_state} = 1;
	    } elsif ($c->req->params->{set_view} eq 'off') {
		$c->model('DB::View')->search({
			no	=> $c->stash->{no},
			user_id	=> $c->user->id
		    })->delete;
		$c->stash->{view_state} = undef;
	    }
	}
	$c->stash->{view_state} ||= $c->model('DB::View')->view_state($c->stash->{no}, $c->user->id);
    }

    $c->stash->{title} .= $c->loc(" :: [_1] ([_2])", $c->enc($rs->get_column('loc_title')), $rs->ryear);
    $c->forward('movies_set_poster');

    #FIXIT: Здесь вопрос, доступ к закачке должен ограничиваться админом через роли
    #if ($c->stash->{user_granted})
    {
	my $rs_path = $c->model('DB::Path')->paths($c->stash->{no});
	$c->stash->{rs_path} = $rs_path;
    }
}

########  EDIT  ###########################################################


########  PRIVATE  ########################################################

sub movies_set_poster :Private {
    my ( $self, $c ) = @_;
    for (split(' ', $c->config->{posters_image_exts})) {
	if (-e $c->config->{upload_poster_path}.$c->stash->{no}.$_) {
	    $c->stash->{poster} = $c->uri_for_static( $c->config->{posters_url_path}.$c->stash->{no}.$_ );
	    last;
	}
    }
    $c->stash->{poster} ||= $c->uri_for_static( $c->config->{poster_default_url} );
}

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
