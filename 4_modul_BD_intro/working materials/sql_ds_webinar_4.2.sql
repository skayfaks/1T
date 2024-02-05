CREATE TYPE gender_type AS ENUM (
  'm', 'w'
);

create table if not exists employees
(
	id serial primary key,
	name varchar(255),
	surname varchar(255),
	birthday date,
	gender gender_type,
	is_auto bool,
	salary integer
)

create table if not exists departments 
(
	id serial primary key, 
	departments_name varchar(100),
	manager_id integer,
    FOREIGN key (manager_id) 
	  REFERENCES employees(id)
	  ON DELETE SET NULL
)

insert into departments
(departments_name, manager_id)
values 
('DA', 1),
('DS', 3),
('DE', 2)

ALTER TABLE employees 
	ADD COLUMN department_id INTEGER,
    ADD CONSTRAINT department_id_fk
   			FOREIGN KEY (department_id)
   			REFERENCES departments (id)
   			ON DELETE SET NULL;

UPDATE employees 
SET department_id = 3
WHERE id in (2, 4)
RETURNING *;




 insert into employees
(name, surname, birthday, gender, is_auto, salary)
values
('Bistrov', 'Sergey', '1998-12-22', 'm', true, 300000),
('Arshavin', 'Andrey', '1994-11-30', 'm', false, 70000),
('Isinbaeva', 'Elena', '1991-05-04', 'w', false, 250000),
('Sharapova', 'Marina', '2000-07-07', 'w', false, 150000),
('Kerzhakov', 'Alexander', '1997-08-03', 'm', true, 120000),
('Pogrebnyak', 'Pavel', '2009-05-24', 'm', true, 30000);


explain select gender, avg(salary) as avg_salary from employees
where (salary >= 200000 and is_auto = true) or salary >= 250000
group by gender;

select age_gr, 
	   count(*) as cnt,
	   avg(salary) as avg_salary
	   from (
			select add_age.*,
					case when age > 17 and age < 25 then 1
						 when age >= 25 and age < 35 then 2
						 when age >=35 and age < 45 then 3
						 else 4 end as age_gr 
			from 
				(select *, 
						date_part('year', age(CURRENT_DATE, date(birthday))) as age
				from employees e) 
				add_age) 
			age_age_gr
group by age_gr
having count(*) >= 2
order by age_gr

with departments_stat as (
select d.departments_name,
	   avg(salary) as avg_salary,
	   count(*) as cnt,
	   max(salary) as max_salary
from employees e 
join departments d 
on e.department_id = d.id
group by d.departments_name
order by avg_salary)
select departments_name from (
select *,
	   max(avg_salary) over() as max_avg_salary
from departments_stat) a
where avg_salary = a.max_avg_salary

with dep_sum_salary as (
select e.id, 
	   e.surname,
	   d.departments_name,
	   e.salary,
	   sum(salary) over(partition by d.departments_name) as dep_salary_sum
from employees e 
join departments d 
on e.department_id = d.id)
select *,
	   round(cast(salary as decimal) /
	   		  dep_salary_sum, 2)*100 as salary_part
from dep_sum_salary

CREATE TABLE calendar (
  day_id DATE NOT NULL PRIMARY KEY,
  year SMALLINT NOT NULL, -- 2012 to 2038
  month SMALLINT NOT NULL, -- 1 to 12
  day SMALLINT NOT NULL, -- 1 to 31
  CONSTRAINT con_month CHECK (month >= 1 AND month <= 12),
  CONSTRAINT con_day CHECK (day >= 1 AND month <= 31),
);

with current_week as (
select cast(generate_series(to_date('27.11.2023','dd.mm.yyyy'),
            to_date('04.12.2023','dd.mm.yyyy'),
            '1 day') as date) as day)
select  c.*, e.id, e.name from current_week c
cross join employees e  
order by id
            
select e.id, e.surname, c.day 
from current_week c
full join employees e
