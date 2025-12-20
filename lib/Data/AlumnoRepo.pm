package Data::AlumnoRepo;

use strict;
use warnings;

sub new {
    my ($class, $dbh) = @_;
    return bless { dbh => $dbh }, $class;
}

# Función para verificar si un email ya existe en la base de datos
sub email_exist {
    my ($self, $email) = @_;
    # Consulta SQL para verificar la existencia del email que solo devuelve 1 si existe para optimizar
    my $sql = q{
        SELECT 1
        FROM alumno
        WHERE email = ?
        LIMIT 1
    };

    # Ejecutar la consulta que verifica la existencia del email
    # Inyectamos el email en la consulta preparada
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute($email);

    return $sth->fetchrow_array ? 1 : 0;
}

sub email_exist_excluding_id {
    my ($self, $email, $id) = @_;

    # Consulta SQL para verificar la existencia del email excluyendo un ID específico
    my $sql = q{
        SELECT 1
        FROM alumno
        WHERE email = ? 
            AND id <> ?
        LIMIT 1
    };

    # Ejecutar la consulta que verifica la existencia del email excluyendo el ID
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute($email, $id);

    return $sth->fetchrow_array ? 1 : 0;
}

# Función para crear un nuevo alumno
sub create {
    my ($self, $data) = @_;

    # Consulta SQL para insertar un nuevo alumno
    my $sql = q{
        INSERT INTO alumno (nombre, email, telefono, nacionalidad, carrera_id)
        VALUES (?, ?, ?, ?, ?)
        RETURNING id
    };

    # Ejecutar la consulta de inserción
    # Inyectamos los datos en la consulta preparada
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute(
        $data->{nombre},
        $data->{email},
        $data->{telefono},
        $data->{nacionalidad},
        $data->{carrera_id}
    );

    my ($id) = $sth->fetchrow_array();
    return $id;
}
# Función para obtener la lista de todos los alumnos
sub list {
    my ($self) = @_;

    # Consulta SQL para obtener todos los alumnos
    my $sql = q{
        SELECT
            a.id,
            a.nombre,
            a.email,
            a.telefono,
            a.nacionalidad,
            a.carrera_id,
            c.nombre AS carrera_nombre
        FROM alumno a
        JOIN carrera c ON a.carrera_id = c.id
        ORDER BY a.id DESC
    };

    # Ejecutar la consulta
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute();

    return $sth->fetchall_arrayref({}) || []; # Retorna un array vacío si no hay resultados
}
# Función para eliminar un alumno por su ID
sub delete {
    my ($self, $id) = @_;
    # Consulta SQL para eliminar un alumno por su ID
    my $sql = q{
        DELETE FROM alumno
        WHERE id = ?
    };

    # Ejecutar la consulta de eliminación
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute($id);

    my $rows = $sth->rows;
    return ($rows > 0) ? 1 : 0; # Retorna 1 si se eliminó un registro, 0 si no
}
#Función para actualizar un alumno por su ID
sub update {
    my ($self, $id, $data) = @_;

    # Consulta SQL para actualizar un alumno por su ID
    my $sql = q{
        UPDATE alumno
        SET nombre = ?,
            email = ?,
            telefono = ?,
            nacionalidad = ?,
            carrera_id = ?
        WHERE id = ?
    };

    # Ejecutar la consulta de actualización
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute(
        $data->{nombre},
        $data->{email},
        $data->{telefono},
        $data->{nacionalidad},
        $data->{carrera_id},
        $id
    );

    my $rows = $sth->rows;
    return ($rows > 0) ? 1 : 0; # Retorna 1 si se actualizó un registro, 0 si no
}
1;
