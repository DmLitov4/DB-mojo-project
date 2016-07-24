package App::User;
use POSIX;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Validator;
use Scalar::Util qw(looks_like_number);
use Digest::MD5 qw(md5 md5_hex md5_base64);

sub renderadd {
    my $self = shift;
    my $sth = $self->app->db->prepare('SELECT * FROM users');
    my $cnt = $self->app->db->prepare('SELECT MAX(id) FROM users');
    $sth->execute;
    $cnt->execute;
    $self->render(template =>'add', user => $sth, cnt => $cnt);
}

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
    if ($filename ne '') {
       $validation->required('exten')->in('.png', '.jpg', '.jpeg');
    }
   
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
          return $self->flash(adderror => "Error occured while adding" . $filename)->redirect_to('/users');
      }
}

sub renderedit {
    my $self = shift;
    return $self->render(template =>'edit');	
}

sub edit_by_id {
    my $self = shift;
    my $idstash = $self->stash('ID');
    my $edit = $self->app->db->prepare('SELECT * FROM users WHERE id=? LIMIT 1');
    $edit->execute($idstash);
    my $row = $edit->fetchrow_arrayref;
    my $name = @$row[1];
    my $email = @$row[2];
    my $money = @$row[4];
    my $pass = @$row[3];
    my $created = @$row[5];

    my $validator  = Mojolicious::Validator->new;
    my $validation = $validator->validation;
    my $checks = $validator->checks;
    $validation->input({email => $email, pass =>$pass});
    $validation->required('email')->like(qr/@{1}/);
    $validation->required('pass') ->size(6, 32);
    
    if ($validation->is_valid) {
        return $self->render(template => 'edit', idn => $idstash, namen => $name, emailn => $email, moneyn => $money, createdn => $created);
    } else {
        return $self->flash(adderror => "Error occured!")->redirect_to('/users');
    }
}

sub edit {
    my $self = shift;

    my $id = $self   ->  param('id');
    my $name = $self ->  param('name');
    my $email = $self->  param('email');
    my $pass = $self ->  param('pass');
    my $money = $self->  param('money');
    my $updated =        strftime('%Y-%m-%d %H:%M:%S',localtime);
    my $created = $self->param('datepicker');
    my $sex = $self->    param('sex');
    
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
    
    my $edit = $self->app->db->prepare('UPDATE users SET id=?, name=?, email=?, pass=?, money=?, updated=?, created=?, sex=? WHERE id=?');
   
    if ($validation->is_valid) {
        my $p = md5($pass);
        if (-e "/home/dmlitov4/proj/public/img/$id.png") {
            unlink "/home/dmlitov4/proj/public/img/$id.png";
        }
        if (-e "/home/dmlitov4/proj/public/img/$id.jpg") {
            unlink "/home/dmlitov4/proj/public/img/$id.jpg";
        }
	$file->move_to("public/img/$id$extension");
        $edit->execute($id, $name, $email, $p, $money, $updated, $created, $sex, $id);
        return $self->flash(savemessage => "Successfully saved!")->redirect_to('/users');
    } else {
        return $self->flash(saveerror => "Error occured!")->redirect_to('/users');
      }
}

sub delete {   
    my $self = shift;
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

