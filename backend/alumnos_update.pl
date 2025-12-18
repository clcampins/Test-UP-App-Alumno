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

my $body = $cgi->param('POSTDATA') || $cgi->param('keywords') || '';
# Si lo anterior falla (depende de la versión de CGI), usa esto:
if (!$body) {
    $body = $cgi->query_string;
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

# Extraer el id del alumno a actualizar
my $id = $payload->{id};

# Validar que el id esté presente y sea un número válido
if (!defined $id || !looks_like_number($id) || $id <= 0) {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '400 Bad Request',
    );
    print encode_json({ error => 'Invalid or missing id' });
    exit;
}

# Validación de campos obligatorios en el JSON para la actualización de un alumno
for my $field (qw(nombre email telefono nacionalidad carrera_id)) {
    if (!defined $payload->{$field} || $payload->{$field} eq '') {
        print $cgi->header(
            -type => 'application/json; charset=UTF-8', 
            -status => '400 Bad Request',
        );
        print encode_json({ error => "Missing or empty field: $field" });
        exit;
    }
}

if($payload->{carrera_id} && (!looks_like_number($payload->{carrera_id}) || $payload->{carrera_id} <= 0)) {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '400 Bad Request',
    );
    print encode_json({ error => 'Invalid carrera_id' });
    exit;
}

my $updated = 0;

# Procesar la actualización del alumno en la base de datos
eval{
    my $dbh = get_dbh();
    # Verificar si el email ya existe excluyendo el ID actual
    if(AlumnoRepo::email_exist_excluding_id($dbh, $payload->{email}, $id)) {
        print $cgi->header(
            -type => 'application/json; charset=UTF-8', 
            -status => '400 Bad Request',
        );
        print encode_json({ error => 'Email already exists' });
        exit;
    }

    $updated = AlumnoRepo::update($dbh, $id, $payload);
    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '500 Internal Server Error',
    );
    print encode_json({ error => 'Internal Server Error' });
    exit;
};

# Respuesta dependiendo si se actualizó o no el alumno
if($updated) {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8',
        -status => '200 OK',
    );
    print encode_json({ message => 'Alumno updated successfully' });
    exit;
}

print $cgi->header(
    -type => 'application/json; charset=UTF-8', 
    -status => '404 Not Found',
);
print encode_json({ error => 'Alumno no encontrado' });
