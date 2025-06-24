use universitysql;

/*Tabla para los ejercicios 1-2-y-3*/
CREATE TABLE person (id INT, first_name VARCHAR(20), age INT, gender CHAR(1));

INSERT INTO person VALUES (1, 'Bob', 25, 'M');
INSERT INTO person VALUES (2, 'Jane', 20, 'F');
INSERT INTO person VALUES (3, 'Jack', 30, 'M');
INSERT INTO person VALUES (4, 'Bill', 32, 'M');
INSERT INTO person VALUES (5, 'Nick', 22, 'M');
INSERT INTO person VALUES (6, 'Kathy', 18, 'F');
INSERT INTO person VALUES (7, 'Steve', 36, 'M');
INSERT INTO person VALUES (8, 'Anne', 25, 'F');
INSERT INTO person VALUES (9, 'Mabel', 18, 'F');   -- Nuevo registro para el 2.a
INSERT INTO person VALUES (10, 'Peter', 22, 'M'); -- Nuevo registro para el 2.b



-- 1.
select rank() over (order by age) as rank_age,
	first_name,
	age,
	gender
from 
	person;

select rank() over (partition by gender order by age) as 'Partido por gender',
	first_name,
	age,
	gender
from 
	person;



-- 2.
SELECT RANK() OVER (ORDER BY age) AS rank_age,
       first_name,
       age,
       gender
FROM 
	person;


SELECT RANK() OVER (PARTITION BY gender ORDER BY age) AS "Partido por gender",
       first_name,
       age,
       gender
FROM
	person;


SELECT DENSE_RANK() OVER (ORDER BY age) AS rank_age,
       first_name,
       age,
       gender
FROM 
	person;


SELECT
    DENSE_RANK() OVER (PARTITION BY gender ORDER BY age) AS "Partido por gender",
    first_name,
    age,
    gender
FROM
    person;



-- 3.
CREATE TABLE student_grade (
    name VARCHAR(50),
    GPA DECIMAL(3, 1)
);

INSERT INTO student_grade (name, GPA) VALUES
('Nick', 4.8),
('Bob', 4.5),
('Anne', 3.9),
('Jane', 3.5),
('Patty', 3.5),
('Steve', 3.2),
('Kathy', 2.9),
('Rey', 2.8),
('Bill', 2.3),
('Charly', 2.1),
('Jack', 1.8),
('Nina', 1.6);


SELECT
    NTILE(3) OVER (ORDER BY GPA DESC) AS tercio,
    name,
    GPA
FROM
    student_grade
ORDER BY
    tercio, GPA DESC;

SELECT
    NTILE(5) OVER (ORDER BY GPA ASC) AS quinto,
    name,
    GPA
FROM
    student_grade
ORDER BY
    quinto, GPA ASC;



-- 4.
SELECT RANK() OVER (ORDER BY grade_to_number(grade) DESC) AS Orden, 
       s.name, 
       grade_to_number(grade) AS Nota
FROM takes t
JOIN student s ON t.id = s.id
WHERE t.course_id = 'CS-101'
ORDER BY grade_to_number(grade) DESC, s.name;

SELECT DENSE_RANK() OVER (ORDER BY grade_to_number(grade) DESC) AS Orden, 
       s.name, 
       grade_to_number(grade) AS Nota
FROM takes t
JOIN student s ON t.id = s.id
WHERE t.course_id = 'CS-101';


SELECT 
    t.ID,
    s.name,
    AVG(grade_to_number(t.grade)) AS Prom
FROM takes t
JOIN student s ON t.ID = s.ID
WHERE s.dept_name = 'Comp. Sci.'
GROUP BY t.ID, s.name
ORDER BY Prom DESC;


SELECT DENSE_RANK() OVER (PARTITION BY s.dept_name ORDER BY AVG(grade_to_number(grade)) DESC) AS Orden,
       s.id,
       s.name,
       AVG(grade_to_number(grade)) AS Prom,
       s.dept_name
FROM takes t
JOIN student s ON t.id = s.id
GROUP BY s.id, s.name, s.dept_name;



-- 5.
SELECT DENSE_RANK() OVER (ORDER BY SUM(grade_to_number(t.grade)) DESC) AS Orden,
       s.id,
       s.name,
       SUM(grade_to_number(t.grade)) AS total
FROM takes t
JOIN student s ON t.id = s.id
GROUP BY s.id, s.name
HAVING COUNT(DISTINCT t.course_id) = 2
ORDER BY total DESC, s.name;


SELECT 
    COUNT(DISTINCT t.course_id) AS Nro_cursos,
    DENSE_RANK() OVER (PARTITION BY COUNT(DISTINCT t.course_id) ORDER BY SUM(grade_to_number(t.grade)) DESC) AS Orden,
    s.id,
    s.name,
    SUM(grade_to_number(t.grade)) AS total
FROM takes t
JOIN student s ON t.id = s.id
GROUP BY s.id, s.name
ORDER BY Nro_cursos, Orden, s.name;



