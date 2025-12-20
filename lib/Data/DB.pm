package Data::DB;

use strict;
use warnings;

use utf8;

use DBI;

use Exporter 'import';
our @EXPORT_OK = qw(get_dbh);

sub get_dbh {
    # Configuración de la conexión a la base de datos
    my $name = "inscripcion_alumnos";
    my $host = "localhost";
    my $port = "5432";
    my $user = "postgres";
    my $password = "1234";
    # Cadena de conexión DSN
    my $dsn = "dbi:Pg:dbname=$name;host=$host;port=$port";

    #Atributos de la conexión
    my %attrs = (
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
        pg_enable_utf8 => 1,
    );

    # Conexión a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, \%attrs);

    return $dbh;
}

1;