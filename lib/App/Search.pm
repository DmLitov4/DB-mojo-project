package App::Search;
use POSIX;
use Mojo::Base 'Mojolicious::Controller';

sub search {
    my $self = shift;
   
    my $name = $self->param('srch');
   
    my $search = eval { $self->app->db->prepare('SELECT * FROM users WHERE name=?') };
    $search->execute($name);
   
    my $searchMail = eval {$self->app->db->prepare('SELECT * FROM users WHERE email=?') };
    $searchMail->execute($name);
    
    $self->render(template =>'searchlist', curSearch => $search, curSearchMail => $searchMail, reques => $name);
}

1;
