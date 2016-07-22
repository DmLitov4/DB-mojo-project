package App::Helpers;
use base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;
    $app->helper(mypluginhelper =>
       sub { return 'Just check!'; });
}

sub logged {
    my $self = shift;
    $self->session('user_id') ? 1 : 0;
}

sub user {
    
}


1;
