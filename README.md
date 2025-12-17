# Test-UP-App-Alumno
Test tecnico de la UP para el puesto de desarrollador fullstack

## Descripción del Proyecto
La aplicación consiste en un ABM de alumnos para gestionar la inscripción a carreras universitarias.
    - **\public**: Contiene un formulario para que se inscriban los alumnos.
    - **\admin**: Contiene un ABM para gestionar a los alumnos y asignarle una carrera.

## Arquitectura
```
/frontend/public          → HTML, CSS, JS (parte pública)
/frontend/admin           → HTML, CSS, JS (parte privada)
/backend         → Scripts Perl (controladores y lógica)
/data            → Acceso a datos (módulos Perl para consultas)
/sql             → Archivo schema.sql para crear la base
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
- Separación de responsabilidades
- Código modular
- Validaciones en backend y frontend
- Diseño responsive

## Definición de Endpoints
### Parte pública
- Lista de carreras en el form:
    **GET** /api/carreras
    Respuesta JSON:
    - 200 Ok:
    [
        {"id": 1, "nombre": "Ingeniería en Inteligencia Artificial"},
        {"id": 2, "nombre": "Informática"},
        {...}...
    ]
    - 500 Error
- Submit de inscripción de alumno:
    **POST** /api/inscripciones
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
    **GET** /api/alumnos
    Respuestas:
    - 200 todo ok:
    [
        {
            "id": 10,
            "nombre": "Carlos",
            "email": "carlos@gmail.com",
            "telefono": "12345678",
            "nacionalidad": "argentina",
            "carrera_id": 2,
            "carrera_nombre": "Informática"
        }
    ]
- Obtener alumno por id
    **GET** /api/alumnos/:id
    Respuestas:
    - 200 Todo ok:
    [
        {
            "id": 10,
            "nombre": "Carlos",
            "email": "carlos@gmail.com",
            "telefono": "12345678",
            "nacionalidad": "argentina",
            "carrera_id": 2,
            "carrera_nombre": "Informática"
        }
    ]
    - 404:
    {
        "error": "Alumno no encontrado"
    }
- Crear alumno
    **POST** /api/alumnos
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
    **PUT** /api/alumnos/:id
    Body JSON:
    {
        "nombre": "Carlos",
        "email": "carlos@gmail.com",
        "telefono": "12345678",
        "nacionalidad": "argentina",
        "carrera_id": 1
    }
    Validación del email, no permite uno repetido.
    Respuestas:
    - 200 Todo ok
    - 404 Datos invalidos
    - 409 Mensaje "El alumno ya está inscripto."
    - 400 Campo faltante
    - 500 Error
- Eliminar alumno
    **DELETE** /api/alumnos/:id
    Respuestas:
    - 204 Todo ok
    - 404 No existe
    - 500 Error


