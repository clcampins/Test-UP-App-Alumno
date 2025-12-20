# Test-UP-App-Alumno
Test técnico de la UP para el puesto de desarrollador fullstack

## Descripción del Proyecto
La aplicación consiste en un Sistema de inscripciones y ABM de alumnos para gestionar la inscripción a carreras universitarias.
- Vistas:
    - **\public**: Contiene un formulario para que se inscriban los alumnos.
    - **\admin**: Contiene un ABM para gestionar a los alumnos y asignarle una carrera.

## Arquitectura
- Actualización: Refactorice el proyecto implementando Arquitectura Limpia DDD de forma simplificada, separando responsabilidades, adicionando una capa de Servicios.

### Capas
```
Frontend (Vue.js)
   ↓
Controllers (CGI Perl)
   ↓
Services (Lógica de negocio)
   ↓
Repositories (Acceso a datos)
   ↓
PostgreSQL
```

### Estructura de carpetas

```
/frontend
  /public          → HTML, CSS, JS (parte pública)
  /admin           → HTML, CSS, JS (parte privada - ABM)

/backend
  /controllers     → Scripts Perl CGI (controladores)

/lib
  /Services        → Servicios (lógica de negocio)
  /Data            → Acceso a datos (repositorios y DB)

/sql
  schema.sql       → Script de creación de la base de datos
```

## Base de Datos

### Nombre de la base
```
inscripcion_alumnos
```

### Modelo de datos
Tablas:

**carrera**
- id (PK)
- nombre (UNIQUE)

**alumno**
- id (PK)
- nombre
- email (UNIQUE)
- telefono
- nacionalidad
- carrera_id (FK → carrera.id)

### Archivo SQL
El script para crear la base es:
```
sql/schema.sql
```
Comando para ejecutar el schema:
```
psql -U postgres -d inscripcion_alumnos -f sql/schema.sql
```

## Principios aplicados:
- Separación de responsabilidades (Controladores | Servicios | Repositorios)
- Inyección de dependencias manual
- Código modular y desacoplado
- Validaciones en backend y frontend
- Mejora de seguridad en las consultas de repositorios 
- Diseño responsive
- Respuestas HTTP con JSON estandarizado

## Seguridad y Validaciones

- Validaciones en frontend y backend.
- Emails únicos verificados a nivel:
  - lógica de negocio
  - constraint de base de datos.
- Uso de **prepared statements** para evitar errores de quotes e inyección SQL.
- Parte privada protegida mediante `.htaccess`.

## Definición de Endpoints
### Parte pública
- Lista de carreras en el form:
    **GET** /api/carreras.pl
    Respuesta JSON:
    - 200 Ok:
    [
        {"id": 1, "nombre": "Ingeniería en Inteligencia Artificial"},
        {"id": 2, "nombre": "Informática"},
        {...}...
    ]
    - 500 Error
- Submit de inscripción de alumno:
    **POST** /api/inscripciones.pl
    Body JSON:
    {
        "nombre": "Carlos",
        "email": "carlos@gmail.com",
        "telefono": "12345678",
        "nacionalidad": "argentina",
        "carrera_id": 1
    }
    Respuestas:
    - 201 Todo ok
    - 409 Mensaje "El alumno ya está inscripto."
    - 400 Campo faltante
    - 500 Error

### Parte privada
- Lista de alumnos:
    **GET** /api/alumnos.pl
    Respuestas:
    - 200 todo ok:
    [
        {
            "alumnos": [
                {
                "id": 10,
                "nombre": "Carlos",
                "email": "carlos@gmail.com",
                "telefono": "12345678",
                "nacionalidad": "Argentina",
                "carrera_id": 2,
                "carrera_nombre": "Informática"
                }
            ]
        }
    ]
- Crear alumno
    **POST** /api/alumnos.pl
    Body JSON:
    {
        "nombre": "Carlos",
        "email": "carlos@gmail.com",
        "telefono": "12345678",
        "nacionalidad": "argentina",
        "carrera_id": 1
    }
    Respuestas:
    - 201 Todo ok
    - 409 Mensaje "El alumno ya está inscripto."
    - 400 Campo faltante
    - 500 Error
- Modificar alumno
    **POST** /api/alumnos.pl/:id
    Body JSON:
    {
        "id": 10,
        "nombre": "Carlos",
        "email": "carlos@gmail.com",
        "telefono": "12345678",
        "nacionalidad": "argentina",
        "carrera_id": 1
    }
    Reglas:
    - id obligatorio.
    - Validación del email, no permite uno repetido.
    - Todos los campos son requeridos.
    Respuestas:
    - 200 Todo ok
    - 404 Not Found — Alumno no encontrado
    - 409 Conflict — Email ya existente
    - 400 Bad Request — Datos inválidos o faltantes
    - 500 Internal Server Error
- Eliminar alumno
    **DELETE** /api/alumnos/:id
    Respuestas:
    - 204 Todo ok
    - 404 No existe
    - 500 Error

## Endpoints del API

### Obtener lista de carreras
- Método: **GET** 
- Endpoint: `/api/carreras.pl`
- Respuesta: 
```json 
{
    "carreras":[
        {"id":7,"nombre":"Administración"},
        {"nombre":"Arquitectura","id":6},
        {"id":3,"nombre":"Ciberseguridad"},
        {"id":5,"nombre":"Electrónica"},
        {"id":2,"nombre":"Informática"},
        {"nombre":"Ingeniería en Inteligencia Artificial","id":1},
        {"id":4,"nombre":"Telecomunicaciones"}
    ]
} 
```

## Pruebas rápidas Curl (CMD)
```
### Listar Alumnos
C:\Users\Usuario>curl -i -X GET http://localhost/Modificar/backend/controllers/alumnos.pl

### Modificar Alumno
C:\Users\Usuario>curl -i -X POST http://localhost/Modificar/backend/controllers/alumnos.pl -H "Content-Type: application/json" -d "{\"id\":1,\"nombre\":\"Carlos\",\"email\":\"carlos@test.com\",\"telefono\":\"12345678\",\"nacionalidad\":\"Argentina\",\"carrera_id\":1}"

### Eliminar Alumno
C:\Users\Usuario>curl -i -X DELETE http://localhost/Modificar/backend/controllers/alumnos.pl -H "Content-Type: application/json" -d "{\"id\":1}"

```

## Configuración de Apache para CGI Perl
```
# habilitar CGI en /api apuntando a la carpeta backend
ScriptAlias /api/ "C:/xampp/htdocs/test_up/Test-UP-App-Alumno/backend/controllers/"

<Directory "C:/xampp/htdocs/test_up/Test-UP-App-Alumno/backend/">
    AllowOverride All
    Options +ExecCGI
    AddHandler cgi-script .pl
    Require all granted
</Directory>

ScriptInterpreterSource Registry
```