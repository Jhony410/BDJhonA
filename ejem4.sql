create database redsocial;
use redsocial;

/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

# 1.
DELIMITER //
CREATE TRIGGER estudiante_muy_afectuoso
AFTER INSERT ON Highschooler
FOR EACH ROW
BEGIN
    IF NEW.name = 'Friendly' THEN
        INSERT INTO Likes (ID1, ID2)
        SELECT NEW.ID, ID
        FROM Highschooler
        WHERE grade = NEW.grade AND ID <> NEW.ID;
    END IF;
END //
DELIMITER ;

INSERT INTO Highschooler (ID, name, grade) VALUES (2000, 'Friendly', 9);
SELECT * FROM Likes WHERE ID1 = 2000;
SELECT * FROM Highschooler;

# 2.
DELIMITER //
CREATE TRIGGER gestionar_grado_estudiante
BEFORE INSERT ON Highschooler
FOR EACH ROW
BEGIN
    IF NEW.grade < 9 OR NEW.grade > 12 THEN
        SET NEW.grade = NULL;
    ELSEIF NEW.grade IS NULL THEN
        SET NEW.grade = 9;
    END IF;
END //
DELIMITER ;

INSERT INTO Highschooler (ID, name, grade) VALUES (2003, 'Oskar', 7);
INSERT INTO Highschooler (ID, name, grade) VALUES (2002, 'Ralph', NULL);
SELECT * FROM Highschooler WHERE ID IN (2002, 2003);

# 3.
DELIMITER //
CREATE TRIGGER eliminar_likes_de_estudiante BEFORE DELETE ON highschooler 
FOR EACH ROW
BEGIN
DELETE FROM likes WHERE ID1 = OLD.ID OR ID2 = OLD.ID;
END // 
DELIMITER ;
INSERT INTO Highschooler values (2025, 'Jhony', 10);
INSERT INTO Likes (ID1, ID2) VALUES (2025, 1782);
INSERT INTO Likes (ID1, ID2) VALUES (2025, 1641);
SELECT * FROM Likes WHERE ID1 = 2025;

DELETE FROM Highschooler WHERE ID = 2025;
SELECT * FROM Likes WHERE ID1 = 2025;

# 4.
DELIMITER //
CREATE TRIGGER romper_amistad_por_cambio_like AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
IF NEW.ID2 <> OLD.ID2 THEN
	DELETE FROM friend
	WHERE (ID1 = NEW.ID2 AND ID2 = OLD.ID2)
	OR (ID1 = OLD.ID2 AND ID2 = NEW.ID2);
END IF; 	
END // 
DELIMITER ;
INSERT INTO Friend VALUES (1709, 1247);
INSERT INTO Friend VALUES (1247, 1709);
INSERT INTO Highschooler VALUES (3002, 'Marjho', 12);
INSERT INTO Likes VALUES (3002, 1709);
SELECT * FROM Friend WHERE (ID1 = 1709 AND ID2 = 1247) OR (ID1 = 1247 AND ID2 = 1709);

UPDATE Likes SET ID2 = 1247 WHERE ID1 = 3002;
SELECT * FROM Friend WHERE (ID1 = 1709 AND ID2 = 1247) OR (ID1 = 1247 AND ID2 = 1709);


# ------------------------------------------- 5 falta ------------------------------------#



# 6.
DELIMITER //
CREATE PROCEDURE agregar_amistad_simetrica(IN id1_val INT, IN id2_val INT)
BEGIN
    INSERT IGNORE INTO Friend (ID1, ID2) VALUES (id1_val, id2_val);
    INSERT IGNORE INTO Friend (ID1, ID2) VALUES (id2_val, id1_val);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE eliminar_amistad_simetrica(IN id1_val INT, IN id2_val INT)
BEGIN
    DELETE FROM Friend WHERE ID1 = id1_val AND ID2 = id2_val;
    DELETE FROM Friend WHERE ID1 = id2_val AND ID2 = id1_val;
END //
DELIMITER ;

CALL agregar_amistad_simetrica(100, 200);
SELECT * FROM Friend;

CALL eliminar_amistad_simetrica(100, 200);
SELECT * FROM Friend;

# 7.
DELIMITER // 
CREATE PROCEDURE actualizarGrade(
	IN ID_student INT, IN GRADE_student INT
	)
	BEGIN 
		DECLARE n INT DEFAULT 0; 
		SELECT grade INTO n FROM highschooler WHERE ID = ID_student; 
		UPDATE highschooler SET grade = GRADE_student WHERE ID = ID_student; 

		IF GRADE_student = n + 1 THEN 

		UPDATE highschooler SET grade = grade + 1
		WHERE ID IN ((SELECT ID2 FROM friend WHERE 
		ID1 = ID_student) UNION (SELECT ID1 FROM friend WHERE ID2 = ID_student));
	END IF; 
END // 
DELIMITER ; 

select * from highschooler; 

call actualizarGrade(1510, 10);
select * from highschooler; 

# 8.
CREATE TABLE historialLikes (
    ID1 INT NOT NULL,
    ID2 INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    usuario VARCHAR(100) NOT NULL
);
DELIMITER //
CREATE TRIGGER registrar_eliminacion_like
AFTER DELETE ON Likes
FOR EACH ROW
BEGIN
    INSERT INTO historialLikes (ID1, ID2, fecha, hora, usuario)
    VALUES (OLD.ID1, OLD.ID2, CURDATE(), CURTIME(), USER());
END //
DELIMITER ;
SELECT * FROM Likes WHERE ID1 = 1641 AND ID2 = 1468;

DELETE FROM Likes WHERE ID1 = 1641 AND ID2 = 1468;
SELECT * FROM historialLikes;


