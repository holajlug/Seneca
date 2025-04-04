-- MGP, JLB

use seneca;

-- 1. CENTRO_EDUCATIVO (1000 registros)
INSERT INTO centro_educativo (nombre, cod_centro, direccion, telefono)
SELECT 
    CONCAT('Centro ', n),
    CONCAT('COD-CEN-', n),
    CONCAT('Calle ', FLOOR(RAND() * 100), ', Ciudad ', n),
    LPAD(FLOOR(RAND() * 1000000000), 9, '0')
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 2. CICLO_FORMATIVO (1000 registros)
INSERT INTO ciclo_formativo (cod_ciclo, nombre, descripcion, horas)
SELECT 
    CONCAT('CIC-', n),
    CONCAT('Ciclo ', n),
    CONCAT('Descripción del ciclo ', n),
    FLOOR(RAND() * 2000 + 500)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 3. PROFESOR (1000 registros)
INSERT INTO profesor (dni, nombre, apellidos, email, especialidad)
SELECT 
    CONCAT(LPAD(n, 8, '0'), SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1)),
    CONCAT('Profesor ', n),
    CONCAT('Apellido', FLOOR(RAND()*10), ' ', 'Apellido', FLOOR(RAND()*10)),
    CONCAT('profesor', n, '@example.com'),
    CONCAT('Especialidad ', FLOOR(RAND()*10))
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 4. OFERTA (1000 registros - relaciona centros y ciclos existentes)
INSERT INTO oferta (id_centro, id_ciclo, curso_academico)
SELECT 
    (SELECT id FROM centro_educativo ORDER BY RAND() LIMIT 1),
    (SELECT id FROM ciclo_formativo ORDER BY RAND() LIMIT 1),
    CONCAT('202', FLOOR(RAND()*3 + 3), '-202', FLOOR(RAND()*3 + 4))
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 5. GRUPO (1000 registros - relaciona ofertas y profesores existentes)
INSERT INTO grupo (curso, letra, id_oferta, id_tutor)
SELECT 
    CONCAT(FLOOR(RAND()*3 + 1), 'º'),
    CHAR(FLOOR(RAND()*5 + 65)), -- Letras A-E
    (SELECT id FROM oferta ORDER BY RAND() LIMIT 1),
    (SELECT id FROM profesor ORDER BY RAND() LIMIT 1)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 6. ALUMNO (1000 registros - relaciona grupos existentes)
INSERT INTO alumno (id_escolar, nombre, apellidos, email, fecha_nac, id_grupo)
SELECT 
    CONCAT('AL', LPAD(n, 6, '0')),
    CONCAT('Alumno', n),
    CONCAT('Apellido', FLOOR(RAND()*10), ' ', 'Apellido', FLOOR(RAND()*10)),
    CONCAT('alumno', n, '@example.com'),
    DATE_ADD('2000-01-01', INTERVAL FLOOR(RAND()*365*10) DAY),
    (SELECT id FROM grupo ORDER BY RAND() LIMIT 1)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 7. TUTOR_LEGAL (1000 registros)
INSERT INTO tutor_legal (dni, nombre, apellidos, email)
SELECT 
    CONCAT(LPAD(n, 8, '0'), SUBSTRING('ABCDEFGHIJKLMNOPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1)),
    CONCAT('Tutor', n),
    CONCAT('Apellido', FLOOR(RAND()*10), ' ', 'Apellido', FLOOR(RAND()*10)),
    CONCAT('tutor', n, '@example.com')
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 8. ES_TUTOR_LEGAL (1000 registros - relaciona alumnos y tutores)
INSERT INTO es_tutor_legal (id_tutor_legal, id_alumno)
SELECT 
    (SELECT id FROM tutor_legal ORDER BY RAND() LIMIT 1),
    (SELECT id FROM alumno ORDER BY RAND() LIMIT 1)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers
ON DUPLICATE KEY UPDATE id_tutor_legal = VALUES(id_tutor_legal); -- Evita duplicados

-- 9. ASIGNATURA (1000 registros - relaciona profesores)
INSERT INTO asignatura (cod, nombre, horas_semanales, id_profesor, id_ciclo)
SELECT 
    CONCAT('ASIG-', n),
    CONCAT('Asignatura ', n),
    FLOOR(RAND()*10 + 2),
    (SELECT id FROM profesor ORDER BY RAND() LIMIT 1),
    (SELECT id FROM ciclo_formativo order by rand() limit 1)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 10. SE_MATRICULA (1000 registros - relaciona alumnos y asignaturas)
INSERT INTO se_matricula (id_alumno, id_asignatura, fecha_matriculacion)
SELECT 
    (SELECT id FROM alumno ORDER BY RAND() LIMIT 1),
    (SELECT id FROM asignatura ORDER BY RAND() LIMIT 1),
    DATE_ADD('2023-09-01', INTERVAL FLOOR(RAND()*30) DAY)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers
ON DUPLICATE KEY UPDATE id_asignatura = VALUES(id_asignatura); -- Evita duplicados

-- 11. RESULTADO_APRENDIZAJE (1000 registros - relaciona asignaturas)
INSERT INTO resultado_aprendizaje (cod, descripcion, id_asignatura)
SELECT 
    CONCAT('RA-', n),
    CONCAT('Descripción del resultado de aprendizaje ', n),
    (SELECT id FROM asignatura ORDER BY RAND() LIMIT 1)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 12. CRITERIO_EVALUACION (1000 registros - relaciona resultados)
INSERT INTO criterio_evaluacion (id_ra, cod, descripcion, ponderacion)
SELECT 
    (SELECT id FROM resultado_aprendizaje ORDER BY RAND() LIMIT 1),
    CONCAT('CE-', n),
    CONCAT('Descripción del criterio ', n),
    ROUND(RAND(), 2)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 13. TAREA (1000 registros)
INSERT INTO tarea (cod, nombre, descripcion, fecha_vencimiento)
SELECT 
    CONCAT('TAREA-', n),
    CONCAT('Tarea ', n),
    CONCAT('Descripción de la tarea ', n),
    DATE_ADD('2023-09-01', INTERVAL FLOOR(RAND()*180) DAY)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers;

-- 14. TAREA_DEL_ALUMNO_POR_CRITERIO (1000 registros - relacion compleja)
INSERT INTO tarea_del_alumno_por_criterio (id_alumno, id_tarea, id_criterio, nota)
SELECT 
    (SELECT id FROM alumno ORDER BY RAND() LIMIT 1),
    (SELECT id FROM tarea ORDER BY RAND() LIMIT 1),
    (SELECT id FROM criterio_evaluacion ORDER BY RAND() LIMIT 1),
    ROUND(RAND()*10, 2)
FROM (
    SELECT ROW_NUMBER() OVER () AS n 
    FROM information_schema.columns 
    LIMIT 1000
) AS numbers
ON DUPLICATE KEY UPDATE nota = VALUES(nota); -- Evita duplicados


-- Inserts necesarios para las consultas
-- Insertar un centro educativo
INSERT INTO centro_educativo (nombre, cod_centro, direccion, telefono) 
VALUES ('IES Los Alcores', '29012345', 'Calle Ejemplo, 123, Sevilla', '954123456');

-- Insertar el ciclo formativo DAW
INSERT INTO ciclo_formativo (cod_ciclo, nombre, descripcion, horas) 
VALUES ('DAW', 'Desarrollo de Aplicaciones Web', 'Ciclo formativo de grado superior en desarrollo web', 2000);

-- Insertar la oferta formativa en el centro IES Los Alcores
INSERT INTO oferta (id_centro, id_ciclo, curso_academico) 
VALUES ((SELECT id FROM centro_educativo WHERE nombre = 'IES Los Alcores'), 
        (SELECT id FROM ciclo_formativo WHERE cod_ciclo = 'DAW'), 
        '2024/2025');
        
-- Insertar profesores
INSERT INTO profesor (dni, nombre, apellidos, email, especialidad) 
VALUES ('12345678A', 'Juan', 'Pérez López', 'jperez@ieslosalcores.es', 'Programación'),
       ('87654321B', 'Ana', 'García Martín', 'agarcia@ieslosalcores.es', 'Bases de Datos');

-- Insertar grupo
INSERT INTO grupo (curso, letra, id_oferta, id_tutor) 
VALUES ('1º', 'A', (SELECT id FROM oferta WHERE curso_academico = '2024/2025'), (SELECT id FROM profesor WHERE dni = '12345678A')),
       ('2º', 'B', (SELECT id FROM oferta WHERE curso_academico = '2024/2025'), (SELECT id FROM profesor WHERE dni = '87654321B'));

-- Insertar alumnos
INSERT INTO alumno (id_escolar, nombre, apellidos, email, fecha_nac, id_grupo) 
VALUES ('A1234', 'Carlos', 'Ruiz Fernández', 'cruiz@correo.com', '2005-06-15', (SELECT id FROM grupo WHERE curso = '1º' AND letra = 'A' and id_oferta = '1024')),
       ('A5678', 'Laura', 'Sánchez Gómez', 'lsanchez@correo.com', '2004-09-22', (SELECT id FROM grupo WHERE curso = '2º' AND letra = 'B' and id_oferta = '1024'));

-- Insertar asignaturas de DAW
INSERT INTO asignatura (cod, nombre, horas_semanales, id_profesor, id_ciclo) 
VALUES ('PRG', 'Programación', 6, (SELECT id FROM profesor WHERE dni = '12345678A'), (SELECT id FROM ciclo_formativo WHERE cod_ciclo = 'DAW')),
       ('BD', 'Bases de Datos', 5, (SELECT id FROM profesor WHERE dni = '87654321B'), (SELECT id FROM ciclo_formativo WHERE cod_ciclo = 'DAW'));

-- Insertar matrícula
INSERT INTO se_matricula (id_alumno, id_asignatura, fecha_matriculacion) 
VALUES ((SELECT id FROM alumno WHERE id_escolar = 'A1234'), (SELECT id FROM asignatura WHERE cod = 'PRG'), '2024-09-01'),
       ((SELECT id FROM alumno WHERE id_escolar = 'A5678'), (SELECT id FROM asignatura WHERE cod = 'BD'), '2024-09-01');

-- Insertar resultados de aprendizaje
INSERT INTO resultado_aprendizaje (cod, descripcion, id_asignatura) 
VALUES ('RA1', 'Comprender los fundamentos de la programación', (SELECT id FROM asignatura WHERE cod = 'PRG')),
       ('RA1', 'Diseñar y gestionar bases de datos', (SELECT id FROM asignatura WHERE cod = 'BD'));

-- Insertar criterios de evaluación
INSERT INTO criterio_evaluacion (descripcion, cod, id_ra) 
VALUES ('Escribir código limpio y estructurado', 'C1R1', (SELECT id FROM resultado_aprendizaje WHERE id = 1028)),
       ('Crear bases de datos normalizadas', 'C1R2', (SELECT id FROM resultado_aprendizaje WHERE id = 1029));

-- Insertar tareas
INSERT INTO tarea (nombre, cod, descripcion)
VALUES ('Ejercicio de Bucles', 'Tarea1000', 'Resolver ejercicios con estructuras repetitivas'),
       ('Diseño de Base de Datos', 'Tarea1001', 'Crear un modelo relacional para una aplicación');

-- Relacionar tareas con criterios
INSERT INTO tarea_del_alumno_por_criterio (id_tarea, id_criterio, id_alumno, nota) 
VALUES ((SELECT id FROM tarea WHERE nombre = 'Ejercicio de Bucles'), 
        (SELECT id FROM criterio_evaluacion WHERE descripcion = 'Escribir código limpio y estructurado'), 
        (SELECT id FROM alumno WHERE id_escolar = 'A1234'), 4.5),
       ((SELECT id FROM tarea WHERE nombre = 'Diseño de Base de Datos'), 
        (SELECT id FROM criterio_evaluacion WHERE descripcion = 'Crear bases de datos normalizadas'), 
        (SELECT id FROM alumno WHERE id_escolar = 'A5678'), 9.0);
