-- MGP, JLB

-- Crear la base de datos
drop database if exists seneca;
CREATE DATABASE seneca;
USE seneca;

-- Tabla CENTRO_EDUCATIVO
CREATE TABLE centro_educativo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cod_centro VARCHAR(50) NOT NULL,
    direccion VARCHAR(255),
    telefono CHAR(9)
);

-- Tabla CICLO_FORMATIVO
CREATE TABLE ciclo_formativo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cod_ciclo VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    horas INT
);

-- Tabla OFERTA
CREATE TABLE oferta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_centro INT NOT NULL,
    id_ciclo INT NOT NULL,
    curso_academico VARCHAR(20),
    FOREIGN KEY (id_centro) REFERENCES centro_educativo(id),
    FOREIGN KEY (id_ciclo) REFERENCES ciclo_formativo(id)
);

-- Tabla PROFESOR
CREATE TABLE profesor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni CHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    email VARCHAR(100),
    especialidad VARCHAR(100)
);

-- Tabla GRUPO
CREATE TABLE grupo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    curso VARCHAR(20) NOT NULL,
    letra CHAR(1) ,
    id_oferta INT NOT NULL,
    id_tutor INT NOT NULL,
    FOREIGN KEY (id_oferta) REFERENCES oferta(id),
    FOREIGN KEY (id_tutor) REFERENCES profesor(id)
);

-- Tabla ALUMNO
CREATE TABLE alumno (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_escolar VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    email VARCHAR(100),
    fecha_nac DATE,
    id_grupo INT NOT NULL,
    FOREIGN KEY (id_grupo) REFERENCES grupo(id)
);

-- Tabla TUTOR_LEGAL
CREATE TABLE tutor_legal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dni VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    email VARCHAR(100)
);

-- Tabla ES_TUTOR_LEGAL
CREATE TABLE es_tutor_legal (
    id_tutor_legal INT ,
    id_alumno INT ,
    PRIMARY KEY (id_tutor_legal, id_alumno),
    FOREIGN KEY (id_tutor_legal) REFERENCES tutor_legal(id),
    FOREIGN KEY (id_alumno) REFERENCES alumno(id)
);

-- Tabla ASIGNATURA
CREATE TABLE asignatura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cod VARCHAR(50) UNIQUE ,
    nombre VARCHAR(100) NOT NULL,
    horas_semanales INT,
    id_profesor INT NOT NULL,
    id_ciclo INT NOT NULL,
    FOREIGN KEY (id_ciclo) REFERENCES ciclo_formativo(id),
    FOREIGN KEY (id_profesor) REFERENCES profesor(id)
);

-- Tabla SE_MATRICULA
CREATE TABLE se_matricula (
    id_alumno INT ,
    id_asignatura INT ,
    fecha_matriculacion DATE ,
    PRIMARY KEY (id_alumno, id_asignatura, fecha_matriculacion),
    FOREIGN KEY (id_alumno) REFERENCES alumno(id),
    FOREIGN KEY (id_asignatura) REFERENCES asignatura(id)
);

-- Tabla RESULTADO_APRENDIZAJE
CREATE TABLE resultado_aprendizaje (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cod VARCHAR(50) NOT NULL,
    descripcion TEXT ,
    id_asignatura INT NOT NULL,
    FOREIGN KEY (id_asignatura) REFERENCES ASIGNATURA(id)
);

-- Tabla CRITERIO_EVALUACION
CREATE TABLE criterio_evaluacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_ra INT NOT NULL,
    cod VARCHAR(50) NOT NULL,
    descripcion TEXT,
    ponderacion DECIMAL(3,2),
    FOREIGN KEY (id_ra) REFERENCES resultado_aprendizaje(id),
    CHECK (ponderacion between 0 and 1)
);

-- Tabla TAREA
CREATE TABLE tarea (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cod VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_vencimiento DATE
);

-- Tabla TAREA_DEL_ALUMNO_POR_CRITERIO
CREATE TABLE tarea_del_alumno_por_criterio (
   id_alumno INT , 
   id_tarea INT , 
   id_criterio INT ,
   nota DECIMAL(4,2) CHECK (nota between 0 and 10), 
   PRIMARY KEY (id_alumno, id_tarea, id_criterio), 
   FOREIGN KEY (id_alumno) REFERENCES alumno(id), 
   FOREIGN KEY (id_tarea) REFERENCES tarea(id), 
   FOREIGN KEY (id_criterio) REFERENCES criterio_evaluacion(id)
);
