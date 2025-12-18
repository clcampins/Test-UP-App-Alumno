#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use JSON;

# Incluir los módulos necesarios
use FindBin;
use lib "$FindBin::Bin/../data";
use DB qw(get_dbh);
use AlumnoRepo;

my $cgi = CGI->new;

# Obtener el método HTTP de la solicitud
my $method = $ENV{'REQUEST_METHOD'} // 'GET';
# Verificar que el método sea GET
if($method ne 'GET') {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '405 Method Not Allowed',
    );
    print encode_json({ error => 'Method Not Allowed' });
    exit;
}

my $response_json;

# Obtener la lista de alumnos desde la base de datos
eval {
    # Obtener el manejador de la base de datos
    my $dbh = get_dbh();

    # Obtener la lista de alumnos
    my $alumnos_ref = AlumnoRepo::list($dbh);

    # Preparar la respuesta en JSON
    $response_json = encode_json({ alumnos => $alumnos_ref });
    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '500 Internal Server Error',
    );
    print encode_json({ error => 'Internal Server Error' });
    exit;
};

print $cgi->header(
    -type => 'application/json; charset=UTF-8', 
    -status => '200 OK',
);
print $response_json;

