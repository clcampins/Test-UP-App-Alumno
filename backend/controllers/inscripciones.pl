#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON;

# Incluir los módulos necesarios
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Data::DB qw(get_dbh);
use Data::AlumnoRepo;
use Services::AlumnoService;


my $cgi = CGI->new;
my $json = JSON->new->utf8;

sub enviar_respuesta {
    my ($status, $data) = @_;
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => $status,
    );
    print encode_json($data);
    exit;
}

# Validar el método HTTP
if (($ENV{'REQUEST_METHOD'} // 'GET') ne 'POST'){
    enviar_respuesta('405 Method Not Allowed', { error => 'Method Not Allowed' });
}

# Capturar el Body de la solicitud POST
sub obtener_payload {
    my $body = $cgi->param('POSTDATA') || $cgi->param('POSTDATA') || '';
    if (!$body && ($ENV{CONTENT_LENGTH} // 0) > 0) {
        binmode STDIN;
        read(STDIN, $body, $ENV{CONTENT_LENGTH});
    }
    return $json->decode($body) if $body;
    die { code => 400, message => 'Body de JSON vacío o inválido' };
}

# Decodificar el JSON del Body de la solicitud POST
eval {
    my $data = obtener_payload();

    # Validación de campos obligatorios en el JSON para la inscripción  de un alumno
    for my $field (qw(nombre email telefono nacionalidad carrera_id)) {
        die { code => 400, message => "El campo '$field' es obligatorio" } if !$data->{$field};
    }

    # Inyectar dependencias y crear el alumno
    my $dbh = get_dbh();
    my $alumno_repo = Data::AlumnoRepo->new($dbh);
    my $alumno_service = Services::AlumnoService->new($alumno_repo);

    my $id = $alumno_service->inscribir_alumno($data);
    enviar_respuesta('201 Created', { id => $id });
    1;
} or do {
    my $error = $@ || 'Unknown error';
    my ($status, $message) = ref $error eq 'HASH' ? ($error->{code}, $error->{message}) : (500, 'Internal Server Error');

    enviar_respuesta("$status", { error => $message });
};