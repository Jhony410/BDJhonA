#------------- DISPARADORES ------------#

use universitysql;

create table historial(
id int,
momento varchar(10),
evento varchar(10),
tabla varchar(20),
fecha date
);

# 1
DELIMITER //
create trigger dis_insertarStudent BEFORE INSERT ON student
FOR EACH ROW
BEGIN
insert into historial values(NEW.id, 'ANTES', 'INSERTAR', 'STUDENT', curdate());
END //
DELIMITER ;
insert into student values('00129','Zhang','Comp. Sci.',102);
insert into student values('12045','Shankar','Comp. Sci.',32);
select * from historial;

# 2
DELIMITER //
CREATE TRIGGER dis_actualizarStudent
BEFORE UPDATE ON student
FOR EACH ROW
BEGIN
    insert into historial (id, momento, evento, tabla, fecha)
    values (NEW.ID, 'ANTES', 'ACTUALIZAR', 'STUDENT', curdate());
END //
DELIMITER ;
UPDATE student SET dept_name = 'Comp. Sci.' WHERE ID = '00129';
SELECT * FROM historial;

# 3
DELIMITER //
CREATE TRIGGER dis_eliminarStudent
AFTER DELETE ON student
FOR EACH ROW
BEGIN
	INSERT INTO historial (id, momento, evento, tabla, fecha)
    VALUES (OLD.ID, 'DESPUES', 'ELIMINAR', 'STUDENT', curdate());
END //
DELIMITER ;
DELETE FROM student WHERE ID = '00129';
SELECT * FROM historial;

# 4
DELIMITER //
CREATE TRIGGER setnull_trigger BEFORE UPDATE ON takes
FOR EACH ROW
BEGIN
	IF NEW.grade = ' ' THEN
		SET NEW.grade = null;
	END IF;
END //
DELIMITER ;
update takes set grade=' ' where id ='98988'and course_id='BIO-101';
select * from takes;


# Eliminar: 
DROP TRIGGER IF EXISTS credits_earned;



# 5
DELIMITER //
CREATE TRIGGER credits_earned AFTER UPDATE ON takes
FOR EACH ROW
BEGIN
declare creditos decimal(2,0);
	IF NEW.grade<>'F' AND NEW.grade is not null AND (OLD.grade='F' or OLD.grade is null) then
		select credits into creditos from course where course.course_id=NEW.course_id;
    
		update student
		set tot_cred =  tot_cred + creditos
		where student.id = NEW.id;
	END IF;
END //
DELIMITER ;
SELECT * FROM student WHERE dept_name = 'Physics';

INSERT INTO takes VALUES ('70557', 'PHY-101', '1', 'Fall', 2009, NULL);
UPDATE takes
SET grade = 'A'
WHERE ID = '70557'
  AND course_id = 'PHY-101'
  AND sec_id = '1'
  AND semester = 'Fall'
  AND year = 2009;
SELECT * FROM student WHERE dept_name = 'Physics';

# 6
DELIMITER //
CREATE TRIGGER credits_lost AFTER DELETE ON takes
FOR EACH ROW
BEGIN
  DECLARE creditos DECIMAL(2,0);
  IF OLD.grade <> 'F' AND OLD.grade IS NOT NULL THEN
    SELECT credits INTO creditos
    FROM course
    WHERE course.course_id = OLD.course_id;
    UPDATE student
    SET tot_cred = tot_cred - creditos
    WHERE student.id = OLD.id;
  END IF;
END //
DELIMITER ;

DELETE FROM takes WHERE id = '70557';
SELECT * FROM student WHERE dept_name = 'Physics';

# ------------- Procedimientos almacenados y disparadores -------------#

# 7
CREATE TABLE estadisticas (
  course_id VARCHAR(8), year INT,
  aprobados INT, desaprobados INT,
  PRIMARY KEY (course_id, year)
);

DELIMITER //
CREATE PROCEDURE proc_estadisticaCourse(IN cid VARCHAR(8), IN y INT)
BEGIN
  DECLARE aprob INT;
  DECLARE desaprob INT;
  DECLARE existe INT;

  SELECT COUNT(*) INTO aprob
  FROM takes
  WHERE course_id = cid AND year = y AND grade IS NOT NULL AND grade_to_number(grade) >= 5;

  SELECT COUNT(*) INTO desaprob
  FROM takes
  WHERE course_id = cid AND year = y AND grade IS NOT NULL AND grade_to_number(grade) < 5;

  SELECT COUNT(*) INTO existe FROM estadisticas WHERE course_id = cid AND year = y;

  IF existe = 0 THEN
    INSERT INTO estadisticas(course_id, year, aprobados, desaprobados)
    VALUES (cid, y, aprob, desaprob);
  ELSE
    UPDATE estadisticas
    SET aprobados = aprob,
        desaprobados = desaprob
    WHERE course_id = cid AND year = y;
  END IF;
END //
DELIMITER ;

CALL proc_estadisticaCourse('CS-101', 2009);
SELECT * FROM estadisticas;

INSERT INTO takes VALUES ('70557','CS-101','1','Fall',2009,'F');

CALL proc_estadisticaCourse('CS-101', 2009);
SELECT * FROM estadisticas;




DROP PROCEDURE IF EXISTS proc_estadisticaCourse;


# 8
DELIMITER //
CREATE TRIGGER registrar_notas AFTER INSERT ON takes 
FOR EACH ROW
BEGIN
CALL proc_estadisticaCourse(NEW.course_id, NEW.year); 
END //
DELIMITER ;

INSERT INTO takes VALUES ('00128', 'CS-190', 2, 'Spring', 2009, 'C+');
SELECT * FROM estadisticas;

INSERT INTO takes VALUES ('76543', 'CS-190', 2, 'Spring', 2009, 'D');
SELECT * FROM estadisticas;

