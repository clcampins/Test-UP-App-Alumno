#!C:/xampp/perl/bin/perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use JSON;

# Incluir los módulos necesarios
use FindBin;
use lib "$FindBin::Bin/../data";
use DB qw(get_dbh);
use CarreraRepo;

my $cgi = CGI->new;

#Validar método HTTP
my method = $ENV{'REQUEST_METHOD'} // 'GET';

if ($method ne 'GET') {
    my $payload = encode_json({ error => 'Method Not Allowed' });

    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '405 Method Not Allowed',
    );
    print payload;
    exit;
}

my $response_json;

eval {
    # Obtener el manejador de la base de datos
    my $dbh = get_dbh();

    # Obtener la lista de carreras
    my $carreras_ref = CarreraRepo::list($dbh);

    # Preparar la respuesta en JSON
    $response_json = encode_json({ carreras => $carreras_ref });
} or do {
    my $payload = encode_json({ error => 'Internal Server Error' });

    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '500 Internal Server Error',
    );
    print payload;
    exit;
};

print $cgi->header(
    -type => 'application/json; charset=UTF-8', 
    -status => '200 OK',
);
print $response_json;