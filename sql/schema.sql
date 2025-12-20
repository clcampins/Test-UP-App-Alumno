CREATE TABLE carrera(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE alumno(
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
	telefono VARCHAR(50),
	nacionalidad VARCHAR(100),
	carrera_id INTEGER NOT NULL REFERENCES carrera(id)
);

INSERT INTO carrera (nombre) VALUES
	('Ingeniería en Inteligencia Artificial'),
	('Informática'),
	('Ciberseguridad'),
	('Telecomunicaciones'),
	('Electrónica'),
	('Arquitectura'),
	('Administración');
	