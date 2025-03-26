CREATE TABLE seneca.centro_educativo (
	id INT auto_increment NOT NULL,
	nombre varchar(100) NOT NULL,
	codigo_centro CHAR(8) NOT NULL UNIQUE,
	direccion varchar(200) NOT NULL,
	telefono CHAR(9) NULL,
	CONSTRAINT centro_educativo_pk PRIMARY KEY (id),
)