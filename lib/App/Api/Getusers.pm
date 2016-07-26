package App::Api::Getusers;
use JSON;
use base 'Mojolicious::Controller';
use utf8;
use IO::File;
use Data::Dumper;
use POSIX;
use Encode qw(encode_utf8);

sub getusers {
    my $self = shift;
    my $par = $self->stash('NAME');
    my $sql_query;
    my $statement;
    if ($par eq "all"){
        $sql_query = "SELECT * FROM users";
        $statement = $self->app->db->prepare ($sql_query);  
        $statement->execute(); 
    } else {
          $sql_query = "SELECT * FROM users where email=? or name=?";
          $statement = $self->app->db->prepare ($sql_query);  
          $statement->execute($par, $par); 
      }
     

    my @loop_data = ();

    while (my @data = $statement->fetchrow_array()) {
        push(@loop_data, @data);
    }   

    my $json;
    $json->{"entries"} = \@loop_data;
    my $json_text = to_json($json);
    $json_text = encode_utf8($json_text);
    return $self->render(json => {'status' => 'ok', 'name' => $par, 'list' => $json_text } );
}

1;
