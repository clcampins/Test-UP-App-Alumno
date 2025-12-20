#!C:\Strawberry\perl\bin\perl.exe
use strict;
use warnings;
use utf8;

use CGI;
use JSON;
use FindBin;

use lib "$FindBin::Bin/../../lib";

use Data::DB qw(get_dbh);
use Data::CarreraRepo;
use Services::CarreraService;

my $cgi = CGI->new;
my $json = JSON->new->utf8;

sub enviar_respuesta {
    my ($status, $data) = @_;
    print $cgi->header(
        -type => 'application/json; charset=UTF-8', 
        -status => $status,
    );
    print $json->encode($data);
    exit;
}

# Validar el método HTTP
if (($ENV{'REQUEST_METHOD'} // 'GET') ne 'GET'){
    enviar_respuesta('405 Method Not Allowed', { error => 'Method Not Allowed' });
}

eval {
    # Obtener el manejador de la base de datos y dependencias
    my $dbh = get_dbh();
    my $repo = Data::CarreraRepo->new($dbh);
    my $service = Services::CarreraService->new($repo);

    # Obtener la lista de carreras
    my $carreras = $service->list_carreras();
    enviar_respuesta('200 OK', { carreras => $carreras });
    1;
} or do {
    my $error = $@ || 'Unknown error';

    # Enviar respuesta de error
    enviar_respuesta("500 Internal Server Error", {
         error => "Internal Server Error",
         detail => "$error"
    });
};