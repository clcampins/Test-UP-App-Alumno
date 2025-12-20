#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use JSON;

use FindBin;
use Scalar::Util qw(looks_like_number);

use lib "$FindBin::Bin/../../lib";
use Data::DB qw(get_dbh);
use Data::AlumnoRepo;
use Services::AlumnoService;

my $cgi = CGI->new;
my $json = JSON->new->utf8;
# Obtener el método HTTP de la solicitud
my $method = $ENV{'REQUEST_METHOD'} // 'GET';

# Aca aplico Patron de Diseño Strategy a traves de un dispatcher de métodos

# Mapear métodos HTTP a funciones
my $strategy_map = {
    'GET' => \&execute_list,
    'POST' => \&execute_update,
    'DELETE' => \&execute_delete,
};

eval {
    my $strategy = $strategy_map->{$method} or die { code => 405, message => 'Método no permitido' };

    # Inyectar dependencias
    my $dbh = get_dbh();
    my $alumno_repo = Data::AlumnoRepo->new($dbh);
    my $alumno_service = Services::AlumnoService->new($alumno_repo);

    $strategy->($alumno_service);
    1;
} or do {
    handle_error($@);
};

sub execute_list {
    my ($alumno_service) = @_;
    my $alumnos = $alumno_service->listar_alumnos();
    enviar_respuesta(200, { alumnos => $alumnos });
}

sub execute_update {
    my ($alumno_service) = @_;
    my $data = obtener_payload();

    my $id = $data->{id} or die { code => 400, message => 'El ID del alumno es obligatorio' };

    # Actualizar el alumno
    $alumno_service->actualizar_alumno($id, $data);
    enviar_respuesta(200, { message => 'Alumno actualizado correctamente' });
}

sub execute_delete {
    my ($alumno_service) = @_;
    my $data = obtener_payload();

    my $id = $data->{id} or die { code => 400, message => 'El ID del alumno es obligatorio' };

    # Eliminar el alumno
    $alumno_service->eliminar_alumno($id);
    enviar_respuesta(204);
}

# Función para enviar respuestas HTTP
sub enviar_respuesta {
    my ($status_code, $data) = @_;
    print $cgi->header(-type => 'application/json', -status => $status_code);
    print $json->encode($data);
    exit;
}

sub obtener_payload {
    my $body = $cgi->param('POSTDATA') || $cgi->param('POSTDATA') || '';
    if (!$body && ($ENV{CONTENT_LENGTH} // 0) > 0) {
        binmode STDIN;
        read(STDIN, $body, $ENV{CONTENT_LENGTH});
    }
    return $json->decode($body) if $body;
    die { code => 400, message => 'Body de JSON vacío o inválido' };
}

sub handle_error {
    my ($error) = @_;
    my ($status, $message) = ref $error eq 'HASH' 
        ? ($error->{code}, $error->{message}) 
        : (500, "Error Interno del Servidor: $error");
    enviar_respuesta($status, { error => $message });
}