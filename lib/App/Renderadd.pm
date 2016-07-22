package App::Renderadd;
use Mojo::Base 'Mojolicious::Controller';

sub renderadd {
    my $self = shift;
    my $sth = $self->app->db->prepare('SELECT * FROM users');
    my $cnt = $self->app->db->prepare('SELECT MAX(id) FROM users');
    $sth->execute;
    $cnt->execute;
    $self->render(template =>'add', user => $sth, cnt => $cnt);
}


1;
