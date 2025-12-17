package CarreraRepo;

use strict;
use warnings;

# Función para obtener la lista de carreras
sub list {
    my ($dbh) = @_;

    # Consulta SQL para obtener las carreras
    my $sql = q{
        SELECT id, nombre
        FROM carrera
        ORDER BY nombre
    };

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my @carreras;

    # Recorremos los resultados y los almacenamos en un array de hashes
    while (my $row = $sth->fetchrow_hashref()) {
        push @carreras, $row;
    }

    return \@carreras;
}

1;
