package App::Delete;
use POSIX;
use Mojo::Base 'Mojolicious::Controller';

sub delete {   
    my $self = shift;
    #готовим удаление
    my $delete = $self->app->db->prepare('DELETE FROM users WHERE id=?');
    my $id = $self->param('id');
    $delete->execute($id);
    return $self->flash(deletemessage => "Deleted successfully!")->redirect_to('/users');
}

sub delete_by_id{
    my $self = shift;
    my $delete = $self->app->db->prepare('DELETE FROM users WHERE id=?');
    my $id = $self->stash('ID');
    $delete->execute($id);
    return $self->flash(deletemessage => "Deleted successfully!")->redirect_to('/users');
}


1;
