#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Movies';
all_from 'lib/Movies.pm';

requires 'Catalyst::Runtime' => '5.80024';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Config::JFDI';
requires 'Getopt::Long';
requires 'Locale::Maketext';
requires 'utf8';

requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::StackTrace';

requires 'Catalyst::Authentication::Realm::SimpleDB';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';

requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';

requires 'Digest::MD5';
requires 'GD' => '2.40';
requires 'Catalyst::Plugin::Captcha';
requires 'Catalyst::Plugin::Cache::FastMmap';
requires 'Catalyst::Plugin::UploadProgress';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::Email::Template';
requires 'Email::Send';
requires 'Email::Sender';
requires 'Math::Int64';

requires 'DateTime::Format::MySQL';
requires 'DBIx::Class::EncodedColumn';
requires 'SQL::Translator';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
