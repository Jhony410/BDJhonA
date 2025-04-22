# ----------------- PROCEDIMIENTOS ALMACENADOS ----------------#

use universitysql;

# 1
DELIMITER //
create procedure proc_dept_count(IN dept_name varchar(20), OUT d_count int)
begin
select count(*) into d_count from instructor where instructor.dept_name = dept_name;
end //
DELIMITER ;

call proc_dept_count('Comp. Sci.' ,@dcount);
select @dcount;
call proc_dept_count('Finance' ,@dcount);
select @dcount;
select * from instructor;


# 2
DELIMITER //
create procedure proc_crearDepartamento(
IN dept_name VARCHAR(20),
IN idlnstructor VARCHAR(5),
IN namelnstructor VARCHAR(20)
)
begin
	declare salario decimal(8,2);
	select min(salary) into salario from instructor;
	insert into department values (dept_name, 'Watson', 50000.00);
	insert into instructor values(idlnstructor, namelnstructor , dept_name, salario);
end //
DELIMITER ;

call proc_crearDepartamento( 'Medicine', '20201', 'Gary');
call proc_crearDepartamento( 'Education', '30301', 'Laydi');

select * from instructor;
select * from department;

# 3
DELIMITER //
create procedure proc_addCursoDepartamento( 
IN dept_name VARCHAR(20),
IN id_curso VARCHAR(8),
IN nom_curso VARCHAR(50),
IN creditos decimal(2,0)
)
begin
declare existeDept boolean;
select count(*)>0 into existeDept from department d where d.dept_name=dept_name; if existeDept then
insert into course values (id_curso, nom_curso, dept_name, creditos);
end if; end//
DELIMITER ;

call proc_addCursoDepartamento ('Medicine', 'MED-101', 'Anatomy',3); 
call proc_addCursoDepartamento ('Nursing', 'MED-101', 'Anatomy',3); 
call proc_addCursoDepartamento ('Medicine', 'MED-102', 'Math',3); 
call proc_addCursoDepartamento ('Medicine', 'MED-103', 'Biology I',3); 
call proc_addCursoDepartamento('Medicine', 'MED-104', 'Laboratory I',2); 
call proc_addCursoDepartamento ('Medicine', 'MED-105', 'Chemestry',4);

select*FROM course;

# 4
select * from student;

DELIMITER //
create procedure proc_addEstudianteDepartamento(
    in dept_name varchar(20),
    in nom_estudiante varchar(50)
)
begin
    declare total_estudiantes INT;
    declare nuevo_id VARCHAR(10);
    SELECT COUNT(*) INTO total_estudiantes FROM student;
    SET nuevo_id = 60000 + total_estudiantes + 1;
    INSERT INTO student VALUES (nuevo_id, nom_estudiante, dept_name, 12);
END //
DELIMITER ;

call proc_addEstudianteDepartamento('Medicine' , 'Fernando');
call proc_addEstudianteDepartamento('Medicine' , 'Betsy' ) ;
call proc_addEstudianteDepartamento('Medicine' , 'Sandy');

select * from student where dept_name = 'Medicine' ;

# 5
DELIMITER //
CREATE PROCEDURE proc_estadisticasDepartamento(
    IN dept_name VARCHAR(20),
    OUT num_cursos INT,
    OUT num_instructores INT,
    OUT num_estudiantes INT
)
BEGIN
    SELECT COUNT(*) INTO num_cursos
    FROM course
    WHERE course.dept_name = dept_name;

    SELECT COUNT(*) INTO num_instructores
    FROM instructor
    WHERE instructor.dept_name = dept_name;

    SELECT COUNT(*) INTO num_estudiantes
    FROM student
    WHERE student.dept_name = dept_name;
END //
DELIMITER ;

CALL proc_estadisticasDepartamento('Comp. Sci.', @tcursos, @tinstructors, @testudiantes);
SELECT 'Comp. Sci.', @tcursos, @tinstructors, @testudiantes;

CALL proc_estadisticasDepartamento('Finance', @tcursos, @tinstructors, @testudiantes);
SELECT 'Finance', @tcursos, @tinstructors, @testudiantes;


----- Procedimientos almacenados que imprimen consultas ---------

# 6
DELIMITER //
create procedure proc_getCoursesOfStudent(IN id_student varchar(20))
begin
select course_id, title from course
where course_id in(select course_id from takes where ID = id_student);
end //
DELIMITER ;

CALL proc_getCoursesOfStudent(98988);
CALL proc_getCoursesOfStudent(12345);

select * from student;

# 7
DELIMITER //
CREATE PROCEDURE proc_getAsesoradosOf(IN instructor_id VARCHAR(5))
BEGIN
    SELECT s.ID, s.name
    FROM student s
    WHERE s.ID IN (SELECT s_ID FROM advisor WHERE i_ID = instructor_id);
END //
DELIMITER ;

CALL proc_getAsesoradosOf(22222);
CALL proc_getAsesoradosOf(10101);

# 8
DELIMITER //
CREATE DEFINER=root@localhost PROCEDURE proc_getRankingCourse(
    IN id_ENTRADA VARCHAR(20), 
    IN year INT
)
BEGIN
    SELECT 
        s.name, 
        t.grade, 
        grade_to_number(t.grade) AS Nota
    FROM 
        student AS s
        INNER JOIN takes AS t ON t.ID = s.ID
    WHERE 
        t.year = year 
        AND t.course_id = id_ENTRADA
    ORDER BY 
        grade_to_number(t.grade) DESC, 
        s.name ASC;
END //
DELIMITER ;

CALL proc_getRankingCourse("CS-101", 2009);
CALL proc_getRankingCourse("CS-315", 2010);

# 9
DELIMITER //
CREATE DEFINER=root@localhost PROCEDURE proc_getStatsCourse(
    IN course_id_param VARCHAR(8),
    IN año_param INT
)
BEGIN
    SELECT 
        AVG(grade_to_number(t.grade)) AS Promedio,
        MAX(grade_to_number(t.grade)) AS Nota_Maxima,
        MIN(grade_to_number(t.grade)) AS Nota_Minima
    FROM takes AS t
    WHERE t.course_id = course_id_param AND t.year = año_param;
END //
DELIMITER ;

CALL proc_getStatsCourse("CS-101", 2009);
CALL proc_getStatsCourse("CS-315", 2010);

# 10
DELIMITER //
CREATE DEFINER=root@localhost PROCEDURE proc_getNameMaxMin(
    IN course_id_param VARCHAR(8),
    IN año_param INT
)
BEGIN
    DECLARE nota_max INT;
    DECLARE nota_min INT;
    
    SELECT 
        MAX(grade_to_number(t.grade)), 
        MIN(grade_to_number(t.grade))
    INTO 
        nota_max, 
        nota_min
    FROM takes AS t
    WHERE t.course_id = course_id_param AND t.year = año_param;

    SELECT 
        'Mayor' AS Tipo,
        s.name,
        t.grade,
        grade_to_number(t.grade) AS Nota
    FROM student AS s
    JOIN takes AS t ON s.ID = t.ID
    WHERE t.course_id = course_id_param 
      AND t.year = año_param
      AND grade_to_number(t.grade) = nota_max

    UNION

    SELECT 
        'Menor' AS Tipo,
        s.name,
        t.grade,
        grade_to_number(t.grade) AS Nota
    FROM student AS s
    JOIN takes AS t ON s.ID = t.ID
    WHERE t.course_id = course_id_param 
      AND t.year = año_param
      AND grade_to_number(t.grade) = nota_min;
END //
DELIMITER ;

CALL proc_getNameMaxMin("CS-101", 2009);
CALL proc_getNameMaxMin("CS-315", 2010);


# 11
DELIMITER //
CREATE DEFINER=root@localhost PROCEDURE proc_getAboutCourse(
    IN course_id_param VARCHAR(8),
    IN año_param INT,
    IN tipo_param INT
)
BEGIN
    DECLARE num_cursos INT;
    DECLARE num_instructores INT;
    DECLARE num_estudiantes INT;
    DECLARE nota_max INT;
    DECLARE nota_min INT;

    IF tipo_param = 1 THEN
        SELECT 
            (SELECT name FROM student WHERE ID = t.ID) AS name,
            t.grade,
            grade_to_number(t.grade) AS Nota
        FROM 
            takes AS t
        WHERE 
            t.year = año_param 
            AND t.course_id = course_id_param
        ORDER BY 
            grade_to_number(t.grade) DESC, 
            (SELECT name FROM student WHERE ID = t.ID) ASC;
    
    ELSEIF tipo_param = 2 THEN
        SELECT 
        AVG(grade_to_number(t.grade)) AS Promedio,
        MAX(grade_to_number(t.grade)) AS Nota_Maxima,
        MIN(grade_to_number(t.grade)) AS Nota_Minima
    FROM takes AS t
    WHERE t.course_id = course_id_param AND t.year = año_param;
        
    ELSEIF tipo_param = 3 THEN
        
        SELECT 
            MAX(grade_to_number(t.grade)), 
            MIN(grade_to_number(t.grade))
        INTO 
            nota_max, 
            nota_min
        FROM takes AS t
        WHERE t.course_id = course_id_param AND t.year = año_param;
        
        SELECT 
            'Mayor' AS Tipo,
            (SELECT name FROM student WHERE ID = t.ID) AS name,
            t.grade,
            grade_to_number(t.grade) AS Nota
        FROM takes AS t
        WHERE t.course_id = course_id_param 
            AND t.year = año_param
            AND grade_to_number(t.grade) = nota_max
        UNION
        
        SELECT 
            'Menor' AS Tipo,
            (SELECT name FROM student WHERE ID = t.ID) AS name,
            t.grade,
            grade_to_number(t.grade) AS Nota
        FROM takes AS t
        WHERE t.course_id = course_id_param 
            AND t.year = año_param
            AND grade_to_number(t.grade) = nota_min;
    END IF;
END //
DELIMITER ;

CALL proc_getAboutCourse("CS-315", 2010, 1);
CALL proc_getAboutCourse("CS-101", 2009, 2);
CALL proc_getAboutCourse("CS-101", 2009, 3);

# 12
DELIMITER //
CREATE DEFINER=root@localhost PROCEDURE proc_getAboutCourse_v2(
    IN course_id_param VARCHAR(20), 
    IN año_param INT, 
    IN tipo_param INT
)
BEGIN
    IF tipo_param = 1 THEN
            CALL proc_getRankingCourse(course_id_param, año_param);
    
    ELSEIF tipo_param = 2 THEN
        CALL proc_getStatsCourse(course_id_param, año_param);
    
    ELSEIF tipo_param = 3 THEN
        CALL proc_getNameMaxMin(course_id_param, año_param);
    END IF;
END //
DELIMITER ;

CALL proc_getAboutCourse_v2("CS-315", 2010, 1);
CALL proc_getAboutCourse_v2("CS-101", 2009, 2);
CALL proc_getAboutCourse_v2("CS-101", 2009, 3);
