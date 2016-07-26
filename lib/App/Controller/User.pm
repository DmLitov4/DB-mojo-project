package App::Controller::User;
use POSIX;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Validator;
use Scalar::Util qw(looks_like_number);
use Digest::MD5 qw(md5 md5_hex md5_base64);

sub validateAll {
    my ($email, $pass, $exten) = @_;
    my $validator  = Mojolicious::Validator->new;
    my $validation = $validator->validation;
    my $checks = $validator->checks;
    $validation->input({email => $email, pass =>$pass, exten => $exten});
    $validation->required('email')->like(qr/@{1}/);
    $validation->required('pass') ->size(6, 32);
    if ($exten ne '') {
       $validation->required('exten')->in('.png', '.jpg', '.jpeg');
    }
    return $validation->is_valid;
}

sub setpic {  
    my $self = shift;
    my $file = $self->req->upload('image');
    my $filename = $file->filename;
    my $id = $self->param('id');
    my $where = $self->param('where');
    my ($extension) = $filename =~ /(\.[^.]+)$/;
    $self->validation->input({exten => $extension});
    $self->validation->required('exten')->in('.png', '.jpg', '.jpeg');
    if ($self->validation->has_error) {
        return $self->flash(avaerror => "Pic is not added")->redirect_to('/users');
    }
    $file->move_to("public/img/$id$extension");
    return $self->flash(avamessage => "Pic is added")->redirect_to('/users');  
} 

sub renderadd {
    my $self = shift;
    my $sth = $self->app->db->prepare('SELECT * FROM users');
    my $cnt = $self->app->db->prepare('SELECT MAX(id) FROM users');
    $sth->execute;
    $cnt->execute;
    $self->render(template =>'users/add', user => $sth, cnt => $cnt);
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
    
    my $check = validateAll($email, $pass, $extension);
   
    if ($money eq "" || (!(looks_like_number($money)))) {
        $money = "NULL";
    }
    
    if (!$check) {
        return $self->flash(adderror => "Error occured while adding" . $filename)->redirect_to('/users');
    }   
    my $p = md5($pass);  
    my $insert = $self->app->db->prepare('INSERT INTO users VALUES (?,?,?,?,?,?,?,?)'); 
    $insert->execute($id, $name, $email, $p, $money, $updated, $created, $sex);
    $file->move_to("public/img/$id$extension");
    return $self->flash(addmessage => "Successfully added!")->redirect_to('/users');
}

sub renderedit {
    my $self = shift;
    return $self->render(template =>'users/edit');	
}

sub checkandremove {
    my ($id) = @_;
    if (-e "/home/dmlitov4/proj/public/img/$id.png") {
        unlink "/home/dmlitov4/proj/public/img/$id.png";
    }
    if (-e "/home/dmlitov4/proj/public/img/$id.jpg") {
        unlink "/home/dmlitov4/proj/public/img/$id.jpg";
    }
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

    my $check = validateAll($email, $pass, '');
    
    if ($check) {
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
    
    my $check = validateAll($email, $pass, $extension);
    
    if ($money eq "" || (!(looks_like_number($money)))) {
        $money = "NULL";
    }
    
    my $edit = $self->app->db->prepare('UPDATE users SET id=?, name=?, email=?, pass=?, money=?, updated=?, created=?, sex=? WHERE id=?');
   
    if ($check) {
        my $p = md5($pass);
        if ($extension ne '') {
            checkandremove($id);
	    $file->move_to("public/img/$id$extension");
        }
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
    checkandremove($id);
    return $self->flash(deletemessage => "Deleted successfully!")->redirect_to('/users');
}

sub delete_by_id{
    my $self = shift;
    my $delete = $self->app->db->prepare('DELETE FROM users WHERE id=?');
    my $id = $self->stash('ID');
    $delete->execute($id);
    checkandremove($id);
    return $self->flash(deletemessage => "Deleted successfully!")->redirect_to('/users');
}


1;

