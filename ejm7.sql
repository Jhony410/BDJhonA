-- 0.

create table prerequisitos ( course_id VARCHAR(10), prereq_id VARCHAR(10));

insert into prerequisitos (course_id, prereq_id) VALUES
('BIO-301', 'BIO-101'),
('BIO-399', 'BIO-101'),
('CS-190', 'CS-101'),
('CS-315', 'CS-190'),
('CS-319', 'CS-101'),
('CS-319', 'CS-315'),
('CS-347', 'CS-319');

with recursive rec_prereq(course_id, prereq_id) AS (
    select course_id, prereq_id
    from prerequisitos
    union
    select rec_prereq.course_id, prerequisitos.prereq_id  
    from rec_prereq, prerequisitos
	where rec_prereq.prereq_id = prerequisitos.course_id
)
select * from rec_prereq where course_id = 'CS-347';


-- 1.
create table ParentOf(parent text, child text);

insert into ParentOf (parent, child) values
('Alice','Carol'),
('Bob','Carol'),
('Carol','Dave'),
('Carol','George'),
('Dave','Mary'),
('Eve','Mary'),
('Mary','Frank');

with recursive
	Ancestor(a,d) as (select parent as a, child as d from ParentOf
					union
					select Ancestor.a, ParentOf.child as d
					from Ancestor, ParentOf
					where Ancestor.d = ParentOf.parent)
select a from Ancestor where d = 'Mary';
-- d. Frank, George

insert into ParentOf (parent, child) values
('Abuelo_Eve', 'Padre_Eve'),
('Padre_Eve', 'Madre_Eve'),
('Madre_Eve', 'Eve');

with recursive
	Ancestor(a,d) as (select parent as a, child as d from ParentOf
					union
					select Ancestor.a, ParentOf.child as d
					from Ancestor, ParentOf
					where Ancestor.d = ParentOf.parent)
select a from Ancestor where d = 'Eve';


-- 2.
create table Employee(ID int, salary int);
create table manager(mID int, eID int);
create table Project(name text, mgrID int);

insert into Employee values (123, 100);
insert into Employee values (234, 90);
insert into Employee values (345, 80);
insert into Employee values (456, 70);
insert into Employee values (567, 60);
insert into Manager values (123, 234);
insert into Manager values (234, 345);
insert into Manager values (234, 456);
insert into Manager values (345, 567);
insert into Project values ('X', 123);

with recursive
	Superior as (select * from Manager
	union
	select S.mID, M.eID
	from Superior S, Manager M
	where S.eID = M.mID )
select sum(salary)
from Employee
where ID in
	(select mgrID from Project where name = 'X'
	union
	select eID from Project, Superior
	where Project.name = 'X' AND Project.mgrID = Superior.mID);

-- d.
INSERT INTO Project VALUES ('Y', 234);

with recursive
	Superior as (select * from Manager
	union
	select S.mID, M.eID
	from Superior S, Manager M
	where S.eID = M.mID )
select sum(salary)
from Employee
where ID in
	(select mgrID from Project where name = 'Y'
	union
	select eID from Project, Superior
	where Project.name = 'Y' AND Project.mgrID = Superior.mID);

-- d.
INSERT INTO Project VALUES ('Z', 345);

with recursive
	Superior as (select * from Manager
	union
	select S.mID, M.eID
	from Superior S, Manager M
	where S.eID = M.mID )
select sum(salary)
from Employee
where ID in
	(select mgrID from Project where name = 'Z'
	union
	select eID from Project, Superior
	where Project.name = 'Z' AND Project.mgrID = Superior.mID);

-- d.
insert into Employee values (10, 150);
insert into Employee values (20, 100);
insert into Employee values (30, 100);
insert into Employee values (21, 60);
insert into Employee values (22, 60);
insert into Employee values (31, 80);
insert into Employee values (32, 40);
insert into Manager values (10, 20);
insert into Manager values (10, 30);
insert into Manager values (20, 21);
insert into Manager values (20, 22);
insert into Manager values (30, 31);
insert into Manager values (31, 32);
insert into Project values ('W', 10);

with recursive
	Superior as (select * from Manager
	union
	select S.mID, M.eID
	from Superior S, Manager M
	where S.eID = M.mID )
select sum(salary)
from Employee
where ID in
	(select mgrID from Project where name = 'X'
	union
	select eID from Project, Superior
	where Project.name = 'W' AND Project.mgrID = Superior.mID);


-- 3.
create table Flight (orig text, dest text, airline text, cost int);

insert into Flight (orig, dest, airline, cost) values
('A', 'ORD', 'United', 200),
('ORD', 'B', 'American', 100),
('A', 'PHX', 'Southwest', 25),
('PHX', 'LAS', 'Southwest', 30),
('LAS', 'CMH', 'Frontier', 60),
('CMH', 'B', 'Frontier', 60),
('A', 'B', 'JetBlue', 195);

with recursive
	Route(orig,dest,total) as
	(select orig, dest, cost as total from Flight
	union
	select R.orig, F.dest, cost+total as total
	from Route R, Flight F
	where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B';

-- d.
with recursive
Route(orig, dest, total) as (
  select orig, dest, cost from Flight
  union
  select R.orig, F.dest, R.total + F.cost
  from Route R, Flight F
  where R.dest = F.orig
)
select * from Route
where orig = 'A' and dest = 'B';

with recursive
Route(orig, dest, total) as (
  select orig, dest, cost from Flight
  union
  select R.orig, F.dest, R.total + F.cost
  from Route R, Flight F
  where R.dest = F.orig
)
select * from Route
where orig = 'A' and dest = 'B'
order by total asc
limit 1;

with recursive
Route(orig, dest, total) as (
  select orig, dest, cost from Flight
  union
  select R.orig, F.dest, R.total + F.cost
  from Route R, Flight F
  where R.dest = F.orig
)
select * from Route
where orig = 'A' and dest = 'B'
order by total desc
limit 1;

-- 4.
insert into Flight values ('CMH', 'PHX', 'Frontier', 80);

/*** Solucion 1 ***/
with recursive
	Route(orig,dest,total) as
		(select orig, dest, cost as total from Flight
		union
		select R.orig, F.dest, cost+total as total
		from Route R, Flight F
		where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B';

/*** Solucion 2: La ruta mas barata ***/
with recursive
	Route(orig, dest,total) as
		(select orig, dest, cost as total from Flight
		union
		select R.orig, F.dest, cost+total as total
		from Route R, Flight F
		where R.dest = F.orig
		and cost+total < all (select total from Route R2
							where R2.orig = R.orig and R2.dest = F.dest))
select * from Route
where orig = 'A' and dest = 'B';

/*** Solucion 3.1: Limitar el numero de resultados ***/
with recursive
	Route(orig,dest,total) as
		(select orig, dest, cost as total from Flight
		union
		select R.orig, F.dest, cost+total as total
		from Route R, Flight F
		where R.dest = F.orig)
select * from Route
where orig = 'A' and dest = 'B' limit 20;

/*** Solucion 3.2: Limitar el numero de resultados con minimo ***/
with recursive
	Route(orig, dest,total) as
		(select orig, dest, cost as total from Flight
		union
		select R.orig, F. dest, cost+total as total
		from Route R, Flight F
		where R.dest = = F.orig)
select min(total) from Route
where orig = 'A' and dest = 'B' limit 20;

/*** Solucion 4.1: Forzar el tamaño maximo de la ruta ***/
with recursive
	Route(orig, dest,total, length) as
		(select orig, dest, cost as total, 1 from Flight
		union
		select R.orig, F.dest, cost+total as total, R.length+l as length
		from Route R, Flight F
		where R.length < 10 and R.dest = F.orig)
select * from Route
where orig = 'A' and dest 'B';

/*** Solucion 4.2: Forzar el tamaño maximo de la ruta ***/
with recursive
	Route(orig, dest,total, length) as
		(select orig, dest, cost as total, 1 from Flight
		union
		select R.orig, F.dest, cost+total as total, R.length+l as length
		from Route R, Flight F
		where R.length < 10 and R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest 'B';

/*** Solucion 4.3: Forzar el tamaño maximo de la ruta ***/
with recursive
	Route(orig, dest,total, length) as
		(select orig, dest, cost as total, 1 from Flight
		union
		select R.orig, F.dest, cost+total as total, R.length+l as length
		from Route R, Flight F
		where R.length < 100000 and R.dest = F.orig)
select min(total) from Route
where orig = 'A' and dest 'B';


