package App::Auth;

use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5 md5_hex md5_base64);

sub authorization {
    my $self = shift;
    
    my $login    = $self->param('login');
    my $password = $self->param('password');
    my $pw = md5($password);
    
    my $sth = $self->app->db->prepare('SELECT id, email, pass FROM users WHERE email =? AND pass =?');
    $sth->execute($login, $password);
    
    if (my $row = $sth->fetchrow_arrayref){     
	   $self->session(
               user_id => @$row[0],
               login   => $login)->redirect_to('/users');
    }
    else {
	$self->flash(autherror => "Auth error!")->redirect_to('/users');
    }
}

sub auth {
    my $self = shift;
    $self->render(template =>'auth_form');
}

sub check {
    my $self = shift;
    $self->session('user_id') ? 1 : 0;
}

sub delete {
    my $self = shift;
    $self->session(user_id => '', login => '')->redirect_to('/');
}

1;
