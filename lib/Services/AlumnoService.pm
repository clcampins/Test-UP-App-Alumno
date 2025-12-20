package Services::AlumnoService;

use strict;
use warnings;
use utf8;

sub new {
    my ($class, $repo) = @_;
    return bless { alumno_repo => $repo }, $class;
}

# Función para listar todos los alumnos
sub listar_alumnos {
    my ($self) = @_;
    return $self->{alumno_repo}->list();
}

# Función para inscribir un nuevo alumno
sub inscribir_alumno {
    my ($self, $data) = @_;

    # Verificar si el email ya existe
    if ($self->{alumno_repo}->email_exist($data->{email})) {
        die { code => 409, message => 'El email ya está registrado' };
    }

    # Verificar si el email es diferente de blanco
    if ($data->{email} =~ /^\s*$/) {
        die { code => 400, message => 'El email no puede estar vacío' };
    }

    # Verificar formato correcto de email
    if ($data->{email} !~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/) {
        die { code => 400, message => 'El formato del email es incorrecto' };
    }

    # Verificar formato correcto de telefono
    if ($data->{telefono} !~ /^\+?\d{7,15}$/) {
        die { code => 400, message => 'El formato del teléfono es incorrecto' };
    }

    # Crear el nuevo alumno
    my $id = $self->{alumno_repo}->create($data);
    die { code => 500, message => 'Error al crear el alumno' } unless $id;
    return $id;
}

sub actualizar_alumno {
    my ($self, $id, $data) = @_;

    # Verificar si el email ya existe excluyendo el ID actual
    if ($self->{alumno_repo}->email_exist_excluding_id($data->{email}, $id)) {
        die { code => 409, message => 'El email ya está registrado por otro alumno' };
    }

    # Verificar si el email es diferente de blanco
    if ($data->{email} =~ /^\s*$/) {
        die { code => 400, message => 'El email no puede estar vacío' };
    }

    # Verificar formato correcto de email
    if ($data->{email} !~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/) {
        die { code => 400, message => 'El formato del email es incorrecto' };
    }

    # Verificar formato correcto de telefono
    if ($data->{telefono} !~ /^\+?\d{7,15}$/) {
        die { code => 400, message => 'El formato del teléfono es incorrecto' };
    }

    # Actualizar el alumno
    my $updated = $self->{alumno_repo}->update($id, $data);
    die { code => 404, message => 'Alumno no encontrado' } unless $updated > 0;
    return 1;
}

sub eliminar_alumno {
    my ($self, $id) = @_;

    # Eliminar el alumno
    my $deleted = $self->{alumno_repo}->delete($id);
    die { code => 404, message => 'Alumno no encontrado' } unless $deleted > 0;
    return 1;
}
1;