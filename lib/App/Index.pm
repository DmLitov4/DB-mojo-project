package App::Index;
use Mojo::Base 'Mojolicious::Controller';

sub index {
#query
   my $self = shift;
   my $sth = $self->app->db->prepare('SELECT * FROM users ORDER BY id');
   $sth->execute;
   $self->render(template =>'index', user => $sth);
}

1;
