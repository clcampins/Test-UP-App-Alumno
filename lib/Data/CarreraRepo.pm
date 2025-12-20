package Data::CarreraRepo;

use strict;
use warnings;

# Constructor de la clase CarreraRepo
sub new {
    my ($class, $dbh) = @_;
    return bless { dbh => $dbh }, $class;
}

# Función para obtener la lista de carreras
sub list {
    my ($self) = @_;

    # Consulta SQL para obtener las carreras
    my $sql = q{
        SELECT id, nombre
        FROM carrera
        ORDER BY nombre
    };

    # Ejecutar la consulta
    my $sth = $self->{dbh}->prepare($sql);
    $sth->execute();

    # Array de carreras
    my @carreras;

    # Recorremos los resultados y los almacenamos en un array de hashes
    while (my $row = $sth->fetchrow_hashref()) {
        push @carreras, $row;
    }

    return \@carreras;
}

1;
