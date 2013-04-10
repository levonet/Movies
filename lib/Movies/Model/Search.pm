package Movies::Model::Search;

use strict;
use warnings;
use parent 'Catalyst::Model';

=head1 NAME

Movies::Model::Search - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub search_process {
    my ( $self, $words, $rows, $page) = @_;

    unless (scalar(@{$words})) {
	Movies->log->debug("Wrong query. Please verify your request.");
	return undef;
    }

    my $trigrams = {};
    foreach my $word (@{$words}) {
	if (length($word) > 3) {
	    for (my $i=0; $i < length($word) - 2; $i++) { 
		$trigrams->{substr($word, $i, 3)}++;
	    }
	} else {
	    $trigrams->{$word}++;
	}
    }

    my $cond = {};
    my @tmp;
    foreach my $trigram (keys %{$trigrams}) {
	push(@tmp, { 'me.trigram' => $trigram});
    }
    $$cond{-or} = \@tmp;
    my $rs_sd = Movies->model('DB::SearchDict')->max_weight($cond);
    my $wth = (defined $rs_sd) ? $rs_sd->get_column('maxweight') : 0;

    Movies->log->debug("Total RELEVANT of query [".$wth."]: \"".join('+', @{$words})."\"");

    my $min_relevant = (exists Movies->config->{search_result_limit} && Movies->config->{search_result_limit} =~ m/^\d+$/ )
	    ? 1 / Movies->config->{search_result_limit} : 0;
    if ($wth <= $min_relevant) {
	Movies->log->debug("No results for \"".join('+', @{$words})."\".");
	return undef;
    } elsif ($wth > 1) {
	$wth = 1;
    }

    @tmp = ();
    foreach my $trigram (keys %{$trigrams}) {
	push(@tmp, { 'sdict.trigram' => $trigram});
    }
    $$cond{-or} = \@tmp;

    return Movies->model('DB::General')->list_search($cond, $wth, $rows, $page);
}

sub rebuild_indexes {
    my ( $self ) = @_;

    Movies->log->debug("SEARCH_INDEX_CREATE");

    Movies->model('DB::SearchIndex')->delete;
    Movies->model('DB::SearchDict')->delete;

    my $rs = Movies->model('DB::General')->search(undef, {select => [ 'me.no' ]});
    foreach my $row ($rs->all) {
	$self->search_reindex($row->no);
    }
}

sub search_reindex {
    my ( $self, $no ) = @_;

    Movies->log->debug("SEARCH_INDEX_REBUILD = [".$no."]");

    # Get words for cleanup trigrams
    my $rs = Movies->model('DB::SearchIndex')->search({no => $no});
    my @sids_old = ();
    foreach my $row ($rs->all) {
	push(@sids_old, $row->sid);
    }

    # Delete current SearchIndex
    $rs->delete;

    # Create new index

    # TODO: to config if necessary
    my $index_fields = {
	'DB::General'	  => [ 'orig_title' ],
	'DB::Description' => [ 'title', 'director' ],
	'DB::Path'	  => [ 'note', 'file_name' ]
    };

    # Get all words from DB tables for indexing
    my @words = ();
    foreach my $table (keys %{$index_fields}) {
	foreach my $row (Movies->model($table)->for_index($no)->all) {
	    if ($row) {
		foreach my $col (@{$index_fields->{$table}}) {
		    my $str = $row->get_column($col);
		    $str =~ s/_/ /g;
		    push(@words, uc($+)) while $str =~ m/(\w+)/gx;
		}
	    }
	}
    }
    # Delete duplicates
    my %tmp = ();
    @words = grep { ! $tmp{$_}++ } @words;

    # Split words to trigrams
    my $trigrams = {};
    foreach my $word (@words) {
	if (length($word) > 3) { # conf
	    for (my $i=0; $i < length($word) - 2; $i++) {  #conf
		$trigrams->{substr($word, $i, 3)}++; #conf
	    }
	} else {
	    $trigrams->{$word}++;
	}
    }

    # Add SearchIndex
    foreach my $trigram (keys %{$trigrams}) {
	my $rs_dict = Movies->model('DB::SearchDict')->find({trigram => $trigram});
	unless (defined $rs_dict) {
	    $rs_dict = Movies->model('DB::SearchDict')->create({ trigram => $trigram });
	}

	Movies->model('DB::SearchIndex')->create({
		no	=> $no,
		sid	=> $rs_dict->sid
	    });

	my $rel = Movies->model('DB::SearchIndex')->relevant($rs_dict->sid);

	$rs_dict->update({weight => $rel});
    }

    # Cleanup SearchDict
    foreach my $sid (@sids_old) {
	unless (defined Movies->model('DB::SearchIndex')->relevant($sid)) {
	    Movies->model('DB::SearchDict')->find({sid => $sid})->delete;
	}
    }
}

sub search_indexdel {
    my ( $self, $no ) = @_;

    Movies->log->debug("SEARCH_INDEX_DELETE = [".$no."]");

    # Get list of trigrams
    my $rs = Movies->model('DB::SearchIndex')->search({no => $no});
    my @sids = ();
    foreach my $row ($rs->all) {
	push(@sids, $row->sid);
    }

    # Delete SearchIndex
    $rs->delete;

    # Rebuild SearchDict
    foreach my $sid (@sids) {
	my $rs_dict = Movies->model('DB::SearchDict')->find({sid => $sid});
	my $rel = Movies->model('DB::SearchIndex')->relevant($rs_dict->sid);
	unless (defined $rel) {
	    $rs_dict->delete;
	} else {
	    $rs_dict->update({weight => $rel});
	}
    }

}

1;
