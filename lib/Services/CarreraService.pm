package Services::CarreraService;

use strict;
use warnings;

# Constructor de la clase CarreraService
sub new {
    my ($class, $repo) = @_;
    return bless { carrera_repo => $repo }, $class;
}

# Función para obtener la lista de carreras
sub list_carreras {
    my ($self) = @_;
    # Valido que el repositorio esté definido
    if (!defined $self->{carrera_repo}) {
        die "Carrera repository is not defined";
    }
    return $self->{carrera_repo}->list();
}

1;