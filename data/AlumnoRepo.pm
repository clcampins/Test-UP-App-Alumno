package AlumnoRepo;

use strict;
use warnings;

# Función para verificar si un email ya existe en la base de datos
sub email_exist {
    my ($dbh, $email) = @_;

    # Consulta SQL para verificar la existencia del email que solo devuelve 1 si existe para optimizar
    my $sql = q{
        SELECT 1
        FROM alumno
        WHERE email = ?
        LIMIT 1
    };

    # Ejecutar la consulta que verifica la existencia del email
    my $sth = $dbh->prepare($sql);
    $sth->execute($email);

    my ($existe) = $sth->fetchrow_array();
    return $existe ? 1 : 0;
}

sub email_exist_excluding_id {
    my ($dbh, $email, $id) = @_;

    # Consulta SQL para verificar la existencia del email excluyendo un ID específico
    my $sql = q{
        SELECT 1
        FROM alumno
        WHERE email = ? 
            AND id <> ?
        LIMIT 1
    };

    # Ejecutar la consulta que verifica la existencia del email excluyendo el ID
    my $sth = $dbh->prepare($sql);
    $sth->execute($email, $id);

    my ($existe) = $sth->fetchrow_array();
    return $existe ? 1 : 0;
}

# Función para crear un nuevo alumno
sub create {
    my ($dbh, $data) = @_;

    # Consulta SQL para insertar un nuevo alumno
    my $sql = q{
        INSERT INTO alumno (nombre, email, telefono, nacionalidad, carrera_id)
        VALUES (?, ?, ?, ?, ?)
        RETURNING id
    };

    # Ejecutar la consulta de inserción
    my $sth = $dbh->prepare($sql);
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
    my ($dbh) = @_;

    # Consulta SQL para obtener todos los alumnos
    my $sql = q{
        SElECT
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
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $rows = $sth->fetchall_arrayref({});
    return $rows || []; # Retorna un array vacío si no hay resultados
}
# Función para eliminar un alumno por su ID
sub delete {
    my ($dbh, $id) = @_;

    # Consulta SQL para eliminar un alumno por su ID
    my $sql = q{
        DELETE FROM alumno
        WHERE id = ?
    };

    # Ejecutar la consulta de eliminación
    my $sth = $dbh->prepare($sql);
    $sth->execute($id);

    my $rows = $sth->rows;
    return ($rows > 0) ? 1 : 0; # Retorna 1 si se eliminó un registro, 0 si no
}
#Función para actualizar un alumno por su ID
sub update {
    my ($dbh, $id, $data) = @_;

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
    my $sth = $dbh->prepare($sql);
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
