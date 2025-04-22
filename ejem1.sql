# ----------------- FUNCIONES ----------------#

use universitysql;

#1
DELIMITER //

CREATE FUNCTION dept_count(dept_name VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE d_count INT;
    SET d_count=0;
    SELECT COUNT(*) INTO d_count 
    FROM instructor 
    WHERE instructor.dept_name=dept_name;
    RETURN d_count;
END//

DELIMITER ;

select dept_name, budget from department where dept_count(dept_name)>2;

#2
DELIMITER //

CREATE FUNCTION budget_level(budget DECIMAL(12,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE budgetlevel VARCHAR(20);

    IF budget<60000 THEN
        SET budgetlevel='PLATINUM';
    ELSEIF budget>=60000 AND budget<=90000 THEN
        SET budgetlevel='SILVER';
    ELSEIF budget>90000 THEN
        SET budgetlevel='GOLD';
    END IF;

    RETURN budgetlevel;
END//

DELIMITER ;

select dept_name, budget_level (budget) from department;

#3
DELIMITER //

CREATE FUNCTION grade_to_number(grade VARCHAR(3))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_value INT;
    SET num_value=0;

    IF grade='A+' THEN
        SET num_value=10;
    ELSEIF grade='A' THEN
        SET num_value=9;
    ELSEIF grade='A-' THEN
        SET num_value=8;
    ELSEIF grade='B+' THEN
        SET num_value=7;
    ELSEIF grade='B' THEN
        SET num_value=7;
    ELSEIF grade='B-' THEN
        SET num_value=7;
    ELSEIF grade='C+' THEN
        SET num_value=5;
    ELSEIF grade='C' THEN
        SET num_value=5;
    ELSEIF grade='C-' THEN
        SET num_value=5;
    ELSEIF grade = 'D+' THEN
        SET num_value = 3;
    ELSEIF grade = 'D' THEN
        SET num_value = 3;
    ELSEIF grade = 'D-' THEN
        SET num_value=3;
    ELSEIF grade='E+' THEN
        SET num_value=2;
    ELSEIF grade='E' THEN
        SET num_value=2;
    ELSEIF grade='E-' THEN
        SET num_value=2;
    ELSEIF grade='F+' THEN
        SET num_value=1;
    ELSEIF grade='F' THEN
        SET num_value=1;
    ELSEIF grade='F-' THEN
        SET num_value=1;
    END IF;

    RETURN num_value;
END//

DELIMITER ;
select ID, sum(grade_to_number(grade)) as Nota from takes group by ID;


#4
SELECT time_slot_id,start_time,end_time FROM time_slot
WHERE TIMEDIFF(end_time, start_time) >= '02:00:00';

#5
SELECT DISTINCT i.ID,i.name FROM instructor i
JOIN teaches t ON i.ID=t.ID
WHERE YEAR(CURDATE())-t.year BETWEEN 14 AND 15;

#6
SELECT s.name,
    IF(s.tot_cred>50,'becado','no becado') AS condicion
FROM student s WHERE s.dept_name='Comp. Sci.';

#7
DELIMITER //
CREATE FUNCTION course_count(student_id VARCHAR(5))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE count_courses INT;
    SELECT COUNT(*) INTO count_courses
    FROM takes
    WHERE ID=student_id;
    RETURN count_courses;
END//
DELIMITER ;

SELECT s.name AS student_name,
	d.dept_name AS department_name,
    course_count(s.ID) AS number_of_courses_taken
FROM student s
JOIN department d ON s.dept_name=d.dept_name
WHERE s.dept_name='Physics';

#8

SELECT id,
CASE semester
    WHEN 'Spring' THEN 'Primavera'
    WHEN 'Summer' THEN 'Verano'
    WHEN 'Fall' THEN 'Otoño'
    ELSE 'Desconocido'
END AS semestre
FROM teaches
WHERE year = 2009;

#9
DELIMITER //
CREATE FUNCTION time_sum(slot_id VARCHAR(10))
returns TIME
DETERMINISTIC
BEGIN
    DECLARE total_seconds INT DEFAULT 0;
    SELECT SUM(TIME_TO_SEC(TIMEDIFF(end_time, start_time)))
    INTO total_seconds
    FROM time_slot
    WHERE time_slot_id = slot_id;
    RETURN SEC_TO_TIME(total_seconds);
END //
DELIMITER ;
DROP FUNCTION IF EXISTS time_sum;

insert into time_slot values( "H" , "M" , "10:00:00", "10:50:00");
SELECT course_id, time_sum(time_slot_id) FROM section WHERE year = 2009;