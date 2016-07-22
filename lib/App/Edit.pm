package App::Edit;
use Mojo::Base 'Mojolicious::Controller';
use POSIX;

sub edit {
    my $self = shift;
    return $self->render(template =>'edit');	
}

sub makeedit_by_id {
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

1;
