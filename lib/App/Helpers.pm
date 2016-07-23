package App::Helpers;
use base 'Mojolicious::Plugin';

sub register {
    my ($self, $app) = @_;
    $app->helper(logged => sub {
        my $self = shift;
        my ($id) = @_;
        if ($self->session->{user_id} == $id) {
            return 1
        } else {
            return $_[0]
          }
        } 
    );
    $app->helper(users => sub {
        my $self = shift;
        my $id = $self->session->{user_id};
        my $sth = $self->app->db->prepare('SELECT * FROM users where id=? LIMIT 1');
        $sth->execute($id);
        my $row = $sth->fetchrow_arrayref;
        return join(' ', @$row);
        }
    );
}


1;
