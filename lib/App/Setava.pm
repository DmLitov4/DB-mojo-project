package App::Setava;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Upload;
use Mojolicious::Validator;

sub setava {  
    my $self = shift;
    my $file = $self->req->upload('image');
    my $filename = $file->filename;
    my $id = $self->param('id');
    my $where = $self->param('where');
    my ($extension) = $filename =~ /(\.[^.]+)$/;
    my $validator  = Mojolicious::Validator->new;
    my $validation = $validator->validation;
    my $checks = $validator->checks;
    $validation->input({exten => $extension});
    $validation->required('exten')->in('.png', '.jpg', '.jpeg');
    if ($validation->is_valid && $where eq 'page') {
        $file->move_to("public/img/$id$extension");
        return $self->redirect_to('/users');
    }
    
    return $self->flash(avaerror => "Pic is not added")->redirect_to('/users');
} 

1;
