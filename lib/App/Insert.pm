package App::Insert;
use POSIX;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Validator;
use Scalar::Util qw(looks_like_number);
use Digest::MD5 qw(md5 md5_hex md5_base64);

sub insert {
    my $self = shift;
    
    my $id = $self->param('id');
    my $name = $self->param('name');
    my $email = $self->param('email');
    my $pass = $self->param('pass');
    my $money = $self->param('money');
    my $updated = strftime('%Y-%m-%d %H:%M:%S',localtime);
    my $created = $self->param('datepicker');
    my $sex = $self->param('sex');
    
    my $file = $self->req->upload('image');
    my $filename = $file->filename;
    my ($extension) = $filename =~ /(\.[^.]+)$/;
    
    my $validator  = Mojolicious::Validator->new;
    my $validation = $validator->validation;
    my $checks = $validator->checks;
    $validation->input({name => $name, email => $email, pass =>$pass, exten => $extension});
    $validation->required('email')->like(qr/@{1}/);
    $validation->required('pass')->size(6, 32);
    $validation->required('exten')->in('.png', '.jpg', '.jpeg');
   
    if ($money eq "" || (!(looks_like_number($money)))) {
        $money = "NULL";
    }
    
    if ($validation->is_valid) {
        my $p = md5($validation->param('pass'));  
        my $insert = $self->app->db->prepare('INSERT INTO users VALUES (?,?,?,?,?,?,?,?)'); 
        $insert->execute($id, $name, $validation->param('email'), $p, $money, $updated, $created, $sex);
        $file->move_to("public/img/$id$extension");
        return $self->flash(addmessage => "Successfully added!")->redirect_to('/users');
    } else {
          return $self->flash(adderror => "Error occured while adding")->redirect_to('/users');
      }
}

1;
