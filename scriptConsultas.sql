-- MGP, JLB
use seneca;

-- Consultas
-- Nota media del RA1 de la asignatura “Bases de datos” por cada alumno
select tac.id_alumno, round(avg(tac.nota), 2) media_bd
from tarea_del_alumno_por_criterio tac
	join criterio_evaluacion c on c.id = tac.id_criterio
	join resultado_aprendizaje ra on ra.id = c.id_ra
    join asignatura a on a.id = ra.id_asignatura
where ra.cod = "RA1"
    and a.nombre = 'Bases de Datos'
group by tac.id_alumno;

-- Nombre y apellidos del alumno que ha obtenido mayor nota en cualquier criterio de
-- evaluación de cualquier módulo profesional (o asignatura)
select a.nombre, a.apellidos, max(tac.nota) mayor_nota
from alumno a
	join tarea_del_alumno_por_criterio tac on tac.id_alumno = a.id
group by a.id
order by mayor_nota desc
limit 1;

-- Nota media de una asignatura cualquiera
select ra.id_asignatura, round(avg(tac.nota), 2) nota_media_de_la_asignatura
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
select idAlumno, nombreAlumno, nombreAsignatura, round(avg(media_ponderada_ra), 2) media_expediente
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
-- ATENCIÓN. Si en alguna ejecución no devuelve datos, volver a ejecutar el scriptDML.sql
-- para que Alumno1 se matricule en más asignaturas
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
select nombreAlumno, nombreAsignatura, round(avg(media_ponderada_ra), 2) media_asignatura
from AlumnoRA
where idAlumno = 1
group by idAlumno, nombreAsignatura
;

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
with AsignaturaSuspensos as(
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
	select nombreAsignatura, count(*) num_suspensos
	from AlumnoRA
	where media_ponderada_ra < 5
	group by nombreAsignatura
)
select p.nombre, p.apellidos, AsignaturaSuspensos.*
from AsignaturaSuspensos
	join asignatura asg on AsignaturaSuspensos.nombreAsignatura = asg.nombre
    join profesor p on p.id = asg.id_profesor
where AsignaturaSuspensos.num_suspensos = (select max(num_suspensos) from AsignaturaSuspensos)
;

-- Muestra los alumnos matriculados en el IES Los Alcores
select a.*, ce.nombre NombreCentro
from alumno a
	join grupo g on g.id = a.id_grupo
    join oferta o on o.id = g.id_oferta
    join centro_educativo ce on ce.id = o.id_centro
where ce.nombre = 'IES Los Alcores';
    
    
    
    
    
    
    
    
    