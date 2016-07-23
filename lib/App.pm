package App;
use Mojo::Base 'Mojolicious';
use DBI;
use Config::Simple;
use Mojolicious::Plugin::Config;
use Mojolicious::Static;

has db  => sub {
    my $self = shift;
    my $config = $self   -> plugin('Config' => {file => 'db.conf'});
    my $dsn    = $config -> {dsn};
    my $user   = $config -> {user};
    my $pass   = $config -> {password};
    my $dbh    = DBI->connect($dsn, $user, $pass);
    return $dbh;
};

sub startup {
    my $self = shift;
    my $r = $self->routes;
    $self->plugin('App::Helpers');
    $self->sessions->default_expiration(3600*24*7);    

    $r->        get('/')                 ->   to('index#index');
    $r->        get('/users')            ->   to('index#index');
    $r->        get('/login')            ->   to('auth#auth')                 -> name('login');
    $r->        get('/api/users')        ->   to('Api::Getusers#getusers')    -> name('getusers');
    $r->        post('/authr')           ->   to('auth#authorization')        -> name('aut');

    my $rn =    $r->under()              ->   to('auth#check');
    
    $rn->       post('/set_ava')         ->   to('setava#setava')             -> name('setava');
    $rn->       post('/insert')          ->   to('insert#insert');
    $rn->       post('/delete')          ->   to('delete#delete');
    $rn->       post('/makeedit')        ->   to('makeedit#makeedit');           
    $rn->       post('/search')          ->   to('search#search');
    $rn->       get('/users/:ID/edit')   ->   to('renderedit#makeedit_by_id');
    $rn->       get('/users/add')        ->   to('renderadd#renderadd')        -> name('useradd');
    $rn->       get('/users/:ID/remove') ->   to('delete#delete_by_id');
    $rn->       get('/users/edit')       ->   to('renderedit#edit');
    $rn->       get('/users/out')        ->   to('auth#delete');  
}


1;

