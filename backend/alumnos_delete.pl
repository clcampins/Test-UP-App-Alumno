#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use JSON;

use Scalar::Util qw(looks_like_number);

# Incluir los módulos necesarios
use FindBin;
use lib "$FindBin::Bin/../data";
use DB qw(get_dbh);
use AlumnoRepo;

my $cgi = CGI->new;

# Obtener el método HTTP de la solicitud
my $method = $ENV{'REQUEST_METHOD'} // 'GET';
# Verificar que el método sea POST
if($method ne 'POST') {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '405 Method Not Allowed',
    );
    print encode_json({ error => 'Method Not Allowed' });
    exit;
}

# my $content_length = $ENV{'CONTENT_LENGTH'} // 0;
# my $body = '';
# if ($content_length > 0) {
#     read(STDIN, $body, $content_length);
# }

# my $body = $cgi->param('POSTDATA') || $cgi->param('keywords') || '';
# # Si lo anterior falla (depende de la versión de CGI), usa esto:
# if (!$body) {
#     $body = $cgi->query_string;
# }
my $body = $cgi->param('POSTDATA') || $cgi->param('.POSTDATA') || '';

if (!$body && ($ENV{'CONTENT_LENGTH'} // 0) > 0) {
    binmode STDIN;
    read(STDIN, $body, $ENV{'CONTENT_LENGTH'});
}

my $payload;
# Decodificar el JSON del cuerpo de la solicitud POST
eval { 
    $payload = decode_json($body);
    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '400 Bad Request',
    );
    print encode_json({ error => 'Invalid JSON' });
    exit;
};

my $id = $payload->{id};

# Validar que el id esté presente y sea un número válido
if(!defined $id || !looks_like_number($id) || $id <= 0) {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '400 Bad Request',
    );
    print encode_json({ error => 'Invalid or missing id' });
    exit;
}

my $deleted = 0;

eval {
    my $dbh = get_dbh();
    $deleted = AlumnoRepo::delete($dbh, $id);
    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '500 Internal Server Error',
    );
    print encode_json({ error => 'Internal Server Error' });
    exit;
};

# Respuesta dependiendo si se eliminó o no el alumno
if($deleted) {
    print $cgi->header(
        -status => '204 No Content',
    );
    exit;
}

print $cgi->header(
    -type => 'application/json; charset=UTF-8', 
    -status => '404 Not Found',
);
print encode_json({ error => 'Alumno not found' });