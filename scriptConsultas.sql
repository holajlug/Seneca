-- MGP, JLB
use seneca;

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

-- Consultas
-- Nota media del RA1 de la asignatura “Bases de datos” por cada alumno
select avg(tac.nota)
from tarea_del_alumno_por_criterio tac
	join criterio_evaluacion c on c.id = tac.id_criterio
	join resultado_aprendizaje ra on ra.id = c.id_ra
    join asignatura a on a.id = ra.id_asignatura
where ra.cod = "RA1"
    and a.nombre = 'Bases de Datos';

-- Nombre y apellidos del alumno que ha obtenido mayor nota en cualquier criterio de
-- evaluación de cualquier módulo profesional (o asignatura)
select a.nombre, a.apellidos, max(tac.nota) mayor_nota
from alumno a
	join tarea_del_alumno_por_criterio tac on tac.id_alumno = a.id
group by a.id
order by mayor_nota desc
limit 1;

-- Nota media de una asignatura cualquiera
select avg(tac.nota) nota_media
from tarea_del_alumno_por_criterio tac
	join criterio_evaluacion c on c.id = tac.id_criterio
	join resultado_aprendizaje ra on ra.id = c.id_ra
group by ra.id_asignatura
order by RAND()
limit 1;

-- Nota media de expediente académico para cada alumno
with AlumnoRA as (
	with AlumnoCriterio as (
		select a.id idAlumno, a.nombre nombreAlumno, asg.nombre nombreAsignatura, ra.id RA, c.id CR, avg(tac.nota) media_criterios
		from tarea_del_alumno_por_criterio tac
			join alumno a on a.id = tac.id_alumno
			join criterio_evaluacion c on c.id = tac.id_criterio
			join resultado_aprendizaje ra on ra.id = c.id_ra
			join asignatura asg on asg.id = ra.id_asignatura
		group by a.id, c.id, ra.id, asg.id
	)
	select idAlumno, nombreAlumno, nombreAsignatura, RA, sum(media_criterios * c.ponderacion) media_ponderada_ra
    from AlumnoCriterio
		join criterio_evaluacion c on c.id = AlumnoCriterio.CR
	group by idAlumno, nombreAsignatura, RA
)
select idAlumno, nombreAlumno, nombreAsignatura, round(avg(media_ponderada_ra), 2) media_asignatura
from AlumnoRA
group by idAlumno, nombreAsignatura
;


-- Muestra el/los RA con mayor número de criterios
with CriteriosPorRA as (
    select id_ra, COUNT(*) as num_criterios
    from criterio_evaluacion
    group by id_ra
)
select CriteriosPorRA.id_ra, ra.cod, ra.descripcion, CriteriosPorRA.num_criterios
from CriteriosPorRA 
	join resultado_aprendizaje ra on ra.id = CriteriosPorRA.id_ra
where num_criterios = (select max(num_criterios) from CriteriosPorRA);

-- Para el alumno cuyo primer ID es 1 muestra la nota final por cada módulo
-- profesional


-- Muestra todos los RA suspensos para cada alumno. El listado debe incluir nombre
-- completo del alumno, nombre del módulo y descripción del RA
with AlumnoRA as (
	with AlumnoCriterio as (
		select a.id idAlumno, a.nombre nombreAlumno, asg.nombre nombreAsignatura, ra.id RA, c.id CR, avg(tac.nota) media_criterios
		from tarea_del_alumno_por_criterio tac
			join alumno a on a.id = tac.id_alumno
			join criterio_evaluacion c on c.id = tac.id_criterio
			join resultado_aprendizaje ra on ra.id = c.id_ra
			join asignatura asg on asg.id = ra.id_asignatura
		group by a.id, c.id, ra.id, asg.id
	)
	select idAlumno, nombreAlumno, nombreAsignatura, RA, sum(media_criterios * c.ponderacion) media_ponderada_ra
    from AlumnoCriterio
		join criterio_evaluacion c on c.id = AlumnoCriterio.CR
	group by idAlumno, nombreAsignatura, RA
)
select AlumnoRA.nombreAlumno, a.apellidos, AlumnoRA.nombreAsignatura, ra.descripcion DescripcionRA
from AlumnoRA
	join resultado_aprendizaje ra on ra.id = AlumnoRA.RA
    join alumno a on a.id = AlumnoRA.idAlumno
where AlumnoRA.media_ponderada_ra < 5;

-- Muestra el nombre del profesor que tiene la asignatura con mayor número de
-- suspensos


-- Muestra los alumnos matriculados en el IES Los Alcores
select a.*, ce.nombre NombreCentro
from alumno a
	join grupo g on g.id = a.id_grupo
    join oferta o on o.id = g.id_oferta
    join centro_educativo ce on ce.id = o.id_centro
where ce.nombre = 'IES Los Alcores';
    
    
    
    
    
    
    
    
    