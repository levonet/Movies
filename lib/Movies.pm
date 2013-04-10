package Movies;

use Moose;
use namespace::autoclean;
use utf8;
use Math::Int64 qw(int64);

use Catalyst::Runtime 5.80;

extends 'Catalyst';
use Catalyst qw/
	ConfigLoader
	I18N
	Static::Simple
	Unicode

	StackTrace

	Authentication
	Authorization::Roles

	Session
	Session::Store::FastMmap
	Session::State::Cookie

	Cache::FastMmap
	UploadProgress

	Captcha
    /;
#	Session::Store::Cache
#	Unicode::Encoding

#use Digest::MD5;
#use Template::Provider::Encoding;
#use Template::Stash::ForceUTF8;

our $VERSION = '0.03';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in movies.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name => 'Movies',
	session => { flash_to_stash => 1 },
	'Plugin::ConfigLoader' => {
	    driver => {
		'General' => {
		    -UTF8 => 1,
		    -ExtendedAccess => 1,
		}
	    }
	},
	default_view => 'TT',
	'View::TT' => {
	    ENCODING => 'UTF-8',
	},
	'View::TTEmpty' => {
	    ENCODING => 'UTF-8',
	},
#	static => {
#	    dirs => [ qr/^\d*/ ],
#	},
	# Disable deprecated behavior needed by old applications
	disable_component_resolution_regex_fallback => 1,
    );

# Configure SimpleDB Authentication
__PACKAGE__->config->{'Plugin::Authentication'} = {
	use_session   => 1,
	default => {
	    class           => 'SimpleDB',
	    user_model      => 'DB::User',
	    password_type   => 'self_check'
	},
    };

__PACKAGE__->config->{captcha} = {
	session_name => 'captcha_string',
	new => {
	    width => 80,
	    height => 30,
	    lines => 7,
	    gd_font => 'giant',
	},
	create => [qw/normal rect/],
	particle => [100],
	out => {force => 'jpeg'}
    };

# Start the application
__PACKAGE__->setup();


=head1 NAME

Movies - Catalyst based application

=head1 SYNOPSIS

    script/movies_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Movies::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub uri_for_static {
    my ( $self, $asset ) = @_;
    return ( $self->config->{static_url_path} || '/static/' ) . $asset;
}

sub uri_for_default {
    my ( $self ) = @_;

    my $lang = (exists $self->stash->{'lang'}) ? $self->stash->{'lang'} : $self->check_lang;

    return ( $self->uri_for('/', $lang, 'movies') );
}

sub check_lang {
    my ( $self, $lng ) = @_;
    my $lang = undef;
    my @l;

    if (defined $lng) {
	push(@l, $lng);
    } else {
	for ($self->languages) {
	    for (@{$_}) { push(@l, $_); }
	}
    }
    for (@l) {
	if (exists $self->config->{'localization'}->{$_}) {
	    $lang = $_;
	    last;
	}
    }
    $lang ||= $self->config->{'default_lang'} || 'en';

    return $lang;
}

sub is_lang {
    my ( $self, $lang ) = @_;

    return ( defined $lang && $self->stash->{'lang'} eq $lang );
}

sub uri_lang {
    my ( $self, $lang) = @_;

    my $params = {};
    foreach (qw/page __q q desc_lang set/) {
	$params->{$_} = $self->req->params->{$_} if exists $self->req->params->{$_};
    }

    my $path = $self->stash->{'uri_path'};
    $path =~ s|^/\w+||;
    $path =~ s|^/||;
    return $self->uri_for('/', $lang, $path, $params);
}

sub uri_for_pager {
    my ( $self, $params) = @_;

    foreach (qw/__q q desc_lang set/) {
	$params->{$_} = $self->req->params->{$_} if exists $self->req->params->{$_};
    }
    return $self->uri_for($self->stash->{'uri_path'}, $params);
}

sub enc {
    my ( $self, $str ) = @_;

    utf8::decode($str);
    return $str;
}

sub contain {
    my ( $self, $src, $search ) = @_;

    if (ref $src eq 'ARRAY') {
	foreach (@{$src}) {
	    return 1 if m/$search/;
	}
    } else { # scalar
	return $src =~ m/$search/;
    }
    0;
}


sub genres_TODO {
    my ( $self, $id ) = @_;

    if (! exists $self->config->{'genre_type'} || $self->config->{'genre_type'} eq 'static') {
	return $self->genres($id);
    } elsif (1) {
# Используется как список с поиском функцией c->find_by_id($list,$id)

# создаем список и отдаем его.

    }

}

sub genres {
    my ( $self, $id ) = @_;

    my @list = [
	{ id => 10,	name => $self->loc("Animation") },
	{ id => 15,	name => $self->loc("The children's") },
	{ id => 20,	name => $self->loc("The family") },
	{ id => 25,	name => $self->loc("The love novel") },
	{ id => 30,	name => $self->loc("Sensuality") },
	{ id => 35,	name => $self->loc("Melodrama") },
	{ id => 40,	name => $self->loc("Drama") },
	{ id => 45,	name => $self->loc("Comedy") },
	{ id => 46,	name => $self->loc("Tragicomedy") },
	{ id => 50,	name => $self->loc("Fantasy") },
	{ id => 55,	name => $self->loc("Fantastic") },
	{ id => 60,	name => $self->loc("Mysticism") },
	{ id => 65,	name => $self->loc("The psychological") },
	{ id => 70,	name => $self->loc("Horrors") },
	{ id => 75,	name => $self->loc("Thriller") },
	{ id => 80,	name => $self->loc("The insurgent") },
	{ id => 85,	name => $self->loc("Adventures") },
	{ id => 90,	name => $self->loc("The criminal") },
	{ id => 92,	name => $self->loc("Fighting") },
	{ id => 95,	name => $self->loc("Western") },
	{ id => 100,	name => $self->loc("Detective") },
	{ id => 105,	name => $self->loc("War") },
	{ id => 110,	name => $self->loc("Accident") },
	{ id => 115,	name => $self->loc("The documentary") },
	{ id => 120,	name => $self->loc("The historical") },
	{ id => 125,	name => $self->loc("The scientific") },
	{ id => 126,	name => $self->loc("The training") },
#	{ id => 127,	name => $self->loc('DB ERROR') },
	{ id => 130,	name => $self->loc("The nature") },
	{ id => 135,	name => $self->loc("Sports") },
	{ id => 140,	name => $self->loc("Music") },
	{ id => 145,	name => $self->loc("Musical") },
	{ id => 255,	name => $self->loc("Another") }
    ];
    return @list;
}

sub quality {
    my ( $self ) = @_;

    my @list = [
	{ id =>  0,	name => $self->loc("Unknown") },
	{ id => 10,	name => $self->loc("DVD-Rip") },
	{ id => 15,	name => $self->loc("TV-Rip") },
	{ id => 20,	name => $self->loc("Cam-Rip") },
	{ id => 25,	name => $self->loc("TS") },
	{ id => 30,	name => $self->loc("Sat-Rip") },
	{ id => 35,	name => $self->loc("VHS-Rip") },
	{ id => 40,	name => $self->loc("HDTV-Rip") },
	{ id => 45,	name => $self->loc("HD-Rip 1080") },
	{ id => 50,	name => $self->loc("HD-Rip 720") },
	{ id => 55,	name => $self->loc("DVD-Screen") },
	{ id => 60,	name => $self->loc("BD-Rip") }
    ];
    return @list;
}

sub category {
    my ( $self ) = @_;

    my @list = [
	{ id => 'G',		name => $self->loc("The family") },
	{ id => 'PG',		name => $self->loc("Horror and violence scenes are minimum") },
	{ id => 'PG-13',	name => $self->loc("There are scenes of violence and drugs") },
	{ id => 'R',		name => $self->loc("Materials \"the adult \" character") },
	{ id => 'NC-17',	name => $self->loc("Scenes of sex, violence, not standard lexicon") }
    ];
    return @list;
}

# TODO create class
sub find_by_id {
    my ( $self, $list, $id ) = @_;

    my $ret = "NULL";
    for my $item (@$list) {
	if ($item->{id} == $id) {
	    $ret = $item->{name};
	    last;
	}
    }
    return $ret;
}


sub sec2time {
    my ( $self, $tt ) = @_;

    my $ss = $tt % 60;
    $tt = ($tt - $ss) / 60;
    my $mm = $tt % 60;
    my $hh = ($tt - $mm) / 60;

    return $self->loc('[_3]:[_2]:[_1]',sprintf("%02d", $ss),sprintf("%02d", $mm),sprintf("%02d", $hh));
}

sub sec2timef {
    my ( $self, $tt ) = @_;

    $tt = ($tt - ($tt % 60)) / 60;
    my $mm = $tt % 60;
    my $hh = ($tt - $mm) / 60;

    if ($hh > 0) {
	return $self->loc('[_2] hr. [_1] min.', $mm, $hh);
    } else {
	return $self->loc('[_1] min.', $mm);
    }
}

sub fsize {
    my ( $self, $sz ) = @_;

    return $sz unless ($sz =~ m/^\d+$/ || $sz =~ m/^\d+[.,]\d+$/);

    if ($sz < (1<<10)) {
	return $self->loc("[_1] bytes", $sz);
    } elsif ($sz < (1<<20)) {
	return $self->loc("[_1] Kb", int($sz / ( 1 << 10 )));
    } elsif ($sz < (1<<30)) {
	return $self->loc("[_1] Mb", int($sz / ( 1 << 20 )));
    } else {
	my $i = int64(1);
	if ($sz < ($i<<40)) {
	    return $self->loc("[_1] Gb", sprintf("%.2f", $sz / ( 1 << 30 )));
	} else {
	    return $self->loc("[_1] Tb", sprintf("%.2f", $sz / int( $i << 40 )));
	}
    }
}

#sub n2br { $_[1] =~ s/\n/\<br\>/g; }
sub n2br {
    my ( $self, $str ) = @_;

    $str =~ s/\n/\<br\>/g;

    return $str;
}

# hack
sub dt2d {
    my ( $self, $str ) = @_;

    $str =~ s/T.*$//;

    return $str;
}

sub storage_filename {
    my ( $self, $attr ) = @_;

    my $filename = $self->config->{storage_file_mask};
    $filename =~ s/\%s/$attr->{storage}/g if exists $attr->{storage};
    $filename =~ s/\%n/$attr->{no}/g if exists $attr->{no};
    $filename =~ s/\%r/$attr->{range}/g if exists $attr->{range};
    $filename =~ s/\%f/$attr->{file_name}/g if exists $attr->{file_name};
    return $filename;
}

#sub storage_basename {
#    my ( $self, $filename ) = @_;
#
#    $filename =~ s|.*/(.*)$|$1|;
#
#    return $filename;
#}

sub storage_mkdirs {
    my ( $self, $filename ) = @_;

    my @path = split('/', $filename);
    my $dir = '';
    if ($filename =~ m|^/|) {
	shift @path;
	$dir = '/';
    }
    pop @path;
    foreach (@path) {
	$dir .= $_;
	unless ( -d $dir ) {
	    return unless (mkdir($dir, 0755));
	}
	$dir .= '/';
    }
    1;
}

sub storage_rmdirs {
    my ( $self, $filename ) = @_;

    my $ret = 0;
    my @path = split('/', $filename);
    my @mask = split('/', $self->config->{storage_file_mask});
    while (my $ipath = pop @path) {
	my $imask = pop @mask;
	next if $imask eq '%f';
	if (scalar(grep { $imask eq $_ } @{[ '%n', '%r' ]})) {
	    my $cur_dir = join('/', @path).'/'.$ipath;
	    return 0 unless ( ! -l $cur_dir && -d $cur_dir );
	    if (opendir(DIR, $cur_dir)) {
		my @d = grep { ! /^[.]+$/ } readdir(DIR);
		closedir(DIR);
		return 0 if (@d);
		return 0 unless (rmdir($cur_dir));
		$ret = 1;
	    } else {
		return 0;
	    }
	} else {
	    last;
	}
    }
    return $ret;
}

sub exec_script {
    my ( $self, $script_name, $filename ) = @_;
    my $script;

    return undef unless exists $self->config->{$script_name};
    $script = $self->config->{$script_name};
    $script =~ s/%f/$filename/;
    open(CMD, $script." |") || return undef;
    my $res = <CMD>;
    if (defined $res) {
        chomp($res);
        $res =~ s/^\s+//;
        $res =~ s/\s+$//;
    }
    close(CMD);
    return $res;
}

1;
