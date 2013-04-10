package Movies::Controller::Auth;

use strict;
use Moose;
use Digest::MD5 qw(md5_hex);
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Movies::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 login

=cut

sub login :Global :Args(0) {
    my ( $self, $c ) = @_;

    # Get the username and password from form
    my $username = $c->req->params->{aaa_name} || "";
    my $password = $c->req->params->{aaa_passwd} || "";
    $c->log->debug("login: ".$c->req->params->{aaa_name});

    # If the username and password values were found in form
    if ($username && $password) {
        # Attempt to log the user in
        if ($c->authenticate({ login => $username, password => $password })) {
            # If successful, then let them use the application
	    if ($c->user->active <= 0) {
		$c->stash->{title} = $c->loc("Login");
		$c->stash->{message} = $c->loc("Account '[_1]' not activated or deleted.", $c->user->login);
		$c->stash->{template} = 'message.tt';
		$c->logout;
		return;
	    }
	    $c->user->update({
		    login_time => sprintf("%04d-%02d-%02d %02d:%02d:%02d",sub{($_[5]+1900,$_[4]+1,$_[3],$_[2],$_[1],$_[0])}->(localtime)),
		    login_host => $c->req->address
		});
	    $c->log->debug("OK. Redirect to: ".$c->req->params->{aaa_redir});
	    $c->res->redirect( $c->req->params->{aaa_redir} );
            return;
        }
    }

    # Set an error message
    $c->res->redirect( $c->uri_for('/', $c->req->params->{aaa_lang}, 'auth', 'login', {
	    aaa_redir	=> $c->req->params->{aaa_redir},
	    aaa_name	=> $c->req->params->{aaa_name},
	    auth_err	=> 1
	}) );
}

=head2 logout

=cut

sub logout :Global :Args(0) {
    my ($self, $c) = @_;

    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->res->redirect( $c->uri_for_default );

}

sub auth : Chained('/lang') PathPart('auth') CaptureArgs(0) { }

sub auth_login : Chained('auth') PathPart('login') Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'auth/login.tt';
    $c->stash->{title} = $c->loc("Login");
}

sub auth_signup : Chained('auth') PathPart('signup') Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'auth/signup.tt';
    $c->stash->{title} = $c->loc("Sign up");
}

sub auth_registration : Chained('auth') PathPart('registration') Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->model('DB::User');

    my $params = {};
    my $user = {
	login		=> $c->req->params->{login},
	password	=> $c->req->params->{password},
	email_address	=> $c->req->params->{email_address},
	name		=> $c->req->params->{name},
	active		=> 1,
	login_time	=> sprintf("%04d-%02d-%02d %02d:%02d:%02d",sub{($_[5]+1900,$_[4]+1,$_[3],$_[2],$_[1],$_[0])}->(localtime)),
	login_host	=> $c->req->address
    };
    foreach (qw/login name email_address/) {
	$params->{$_} = $user->{$_};
    }

    if ( ! $c->req->params->{login} ||
	 ! $c->req->params->{password} ||
	 ! $c->req->params->{passwordconfirm} ||
	 ! $c->req->params->{name} ||
	 ! $c->req->params->{email_address} ) {

	$c->log->debug("You have to fill in all required fields");
	$params->{status} = $c->loc("You have to fill in all required fields");
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	return;
    }

    if ( defined $rs->get_user($user->{login}) ) {
	$c->log->debug("That login '[_1]' is already in use, try another name");
	$params->{status} = $c->loc("That login '[_1]' is already in use, try another name", $user->{login});
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	return;
    }

    if ( length($user->{password}) < 6 || $user->{password} ne $c->req->params->{passwordconfirm} ) {
	$c->log->debug("Please verify your password again");
	$params->{status} = $c->loc("Please verify your password again");
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	return;
    }

    unless ( $c->validate_captcha($c->req->param('validate')) ) {
	$c->log->debug("Code does not match");
	$params->{status} = $c->loc("Code does not match");
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	return;
    }

    if ( $c->user_exists && ! $c->check_user_roles('Admins') ) {
#Check it!
	$params->{status} = $c->loc("Please logoff first");
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	return;
    }

    if (exists $c->config->{registration_confirmation} && $c->config->{registration_confirmation} &&
	    ! $c->check_user_roles('Admins') ) {
        $user->{active} = int((1<<31) * rand(1)) * -1;
        if ($user->{active} > 0) {
	    $params->{status} = $c->loc("Some error in creating registration data. Tray again.");
	    $c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'auth', 'signup', $params) );
	    return;
        }
    }

    my $row_user = $c->model('DB::User')->create($user);
    $c->model('DB::UserRole')->create({
	    user_id => $row_user->id,
	    role_id => $c->model('DB::Role')->find({ role => 'Users' })->id
	});

#TODO: send email
#$c->config->{registration_emailpassword}  1

    if (exists $c->config->{registration_confirmation} && $c->config->{registration_confirmation}) {
	$c->stash(
	    user	=> $row_user,
	    digest	=> md5_hex($user->{active}.$user->{email_address}),
	    email	=> {
		from	    => $c->config->{system_mail},
		to	    => $user->{email_address},
		subject	    => $c->loc("[_1] New User Activation", $c->config->{name} ),
		template    => 'validate.tt',
	    },
	);
	$c->forward( $c->view('Email') );
	if ( scalar( @{ $c->error } ) ) {
	    $c->log->debug("An error occourred. Sorry.");
	    foreach (@{ $c->error }) {
		$c->log->debug($_);
	    }
	    $c->clear_errors;
#TODO
#	    $c->stash->{error} = $c->loc("An error occourred. Sorry.");
	}

	$c->stash->{title} = $c->loc("Validation");
	$c->stash->{message} = $c->loc("We've sent you an email with an activation link. Please click on it to activate your account!");
	$c->stash->{message} .= '<br>';
	$c->stash->{message} .= $c->loc("The email was sent to [_1].", $user->{email_address});
	$c->stash->{template} = 'message.tt';
	return;
    }

    if ( $c->check_user_roles('Admins') ) {
	$c->forward('auth_create_user');


	# redirect страница администрирования пользователей
# TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	$c->res->redirect( $c->uri_for('/', $c->stash->{lang}, 'admin', 'users') );
	return;





    } else {
	# Auth if registration OK
	unless ($c->authenticate({ login => $user->{login},
		    password => $user->{password} } )) {
	# Error
	}
	$c->res->redirect( $c->uri_for_default );
	return;
    }
}

sub auth_validate : Chained('auth') PathPart('validate') Args(2) {
    my ($self, $c, $uid, $digest) = @_;

    $c->stash->{template} = 'auth/validate.tt';
    $c->stash->{title} = $c->loc("Validation");

    my $row_user = $c->model('DB::User')->find($uid);

    unless ($row_user) {
	# Error
	$c->log->debug("User not found in db");
	return;
    }
    if ($row_user->active >= 0) {
	$c->stash->{title} = $c->loc("Error");
	$c->stash->{message} = $c->loc("This account already activated");
	$c->stash->{template} = 'message.tt';
	return;
    }

    unless ($digest eq md5_hex($row_user->active.$row_user->email_address)) {
	$c->log->debug("ERROR");
	$c->stash->{title} = $c->loc("Error");
	$c->stash->{message} = $c->loc("");
	$c->stash->{template} = 'message.tt';
	return;
    }

    $row_user->update({ active => 1 });
    $c->stash->{user} = $row_user;

    # Goto default page if login
    $c->stash->{uri_path} = $c->uri_for_default->path;
}

sub captcha : Local {
    my ($self, $c) = @_;
    $c->create_captcha();
}

sub auth_remind : Chained('auth') PathPart('remind') Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'auth/login.tt';
    $c->stash->{title} = $c->loc("Remind password");

# TODO

}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
