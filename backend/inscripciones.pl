#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON;

# Incluir los módulos necesarios
use FindBin;
use lib "$FindBin::Bin/../data";
use DB qw(get_dbh);
use AlumnoRepo;


my $cgi = CGI->new;

my $method = $ENV{'REQUEST_METHOD'} // 'GET';

if($method ne 'POST') {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '405 Method Not Allowed',
    );
    print encode_json({ error => 'Method Not Allowed' });
    exit;
}

# my $content_length = $ENV{'REQUEST_METHOD'} // 0;
# my $body = '';
# if ($content_length > 0) {
#    read(STDIN, $body, $content_length);
# }

# Alternativamente, obtener el cuerpo de la solicitud POST usando CGI.pm
my $body = $cgi->param('POSTDATA') || $cgi->param('keywords') || '';
# Si lo anterior falla (depende de la versión de CGI), usa esto:
if (!$body) {
    $body = $cgi->query_string;
}

my $data;

# Decodificar el JSON del cuerpo de la solicitud POST
eval {
    $data = decode_json($body);
    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '400 Bad Request',
    );
    print encode_json({ error => 'Invalid JSON' });
    exit;
};

# Validación de campos obligatorios en el JSON para la inscripción  de un alumno
for my $field (qw(nombre email telefono nacionalidad carrera_id)) {
    if (!defined $data->{$field} || $data->{$field} eq '') {
        print $cgi->header(
            -type => 'application/json; charset=UTF-8', 
            -status => '400 Bad Request',
        );
        print encode_json({ 
            error => "Validation Error",
            field => $field,
        });
        exit;
    }
}

# Procesar la inscripción del alumno para guardarlo en la base de datos
eval {
    my $dbh = get_dbh();

    # Verificar si el email ya existe
    if (AlumnoRepo::email_exist($dbh, $data->{email})) {
        print $cgi->header(
            -type => 'application/json; charset=UTF-8', 
            -status => '409 Conflict',
        );
        print encode_json({ error => 'Email already exists' });
        exit;
    }

    # Crear el nuevo alumno
    my $id = AlumnoRepo::create($dbh, $data);

    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '201 Created',
    );
    print encode_json({ id => $id });
    exit;

    1;
} or do {
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => '500 Internal Server Error',
    );
    print encode_json({ error => 'Internal Server Error' });
    exit;
};