USE sakila;

# 10.

EXPLAIN SELECT * FROM actor WHERE last_name = 'DAVIS';

EXPLAIN SELECT * FROM customer WHERE last_name = 'SMITH';

EXPLAIN SELECT * FROM film WHERE title = 'ACADEMY DINOSAUR';

EXPLAIN SELECT * FROM city WHERE country_id = 20;

EXPLAIN SELECT * FROM address WHERE city_id = 100;

EXPLAIN SELECT * FROM film_actor WHERE film_id = 10;

EXPLAIN SELECT * FROM payment WHERE customer_id = 1;

EXPLAIN SELECT * FROM rental WHERE inventory_id = 100;

EXPLAIN SELECT * FROM staff WHERE store_id = 1;

EXPLAIN SELECT * FROM store WHERE address_id = 1;

# 11.
EXPLAIN SELECT * FROM actor WHERE last_name LIKE '%SON';

EXPLAIN SELECT * FROM film WHERE title LIKE '%ACADEMY%';

EXPLAIN SELECT * FROM customer WHERE LOWER(last_name) = 'smith';

EXPLAIN SELECT * FROM film WHERE description LIKE '%epic%';

EXPLAIN SELECT * FROM address WHERE address LIKE '%Drive%';

EXPLAIN SELECT * FROM staff WHERE SUBSTRING(username, 2) = 'user';

# 12.
EXPLAIN SELECT * 
FROM actor 
JOIN film_actor USING (actor_id);

-- Variante B: JOIN ON
EXPLAIN SELECT * 
FROM actor A 
JOIN film_actor FA ON A.actor_id = FA.actor_id;

-- Variante C: coma + WHERE
EXPLAIN SELECT * 
FROM actor A, film_actor FA 
WHERE A.actor_id = FA.actor_id;

# 14.
CREATE INDEX idx_year_rating ON film (release_year, rating);

SHOW INDEXES FROM film;

EXPLAIN SELECT film_id, title FROM film WHERE release_year = 2006;

EXPLAIN SELECT film_id, title FROM film WHERE release_year = 2006 AND rating = 'PG';

EXPLAIN SELECT film_id, title FROM film WHERE rating = 'PG-13';

EXPLAIN SELECT release_year, rating FROM film WHERE release_year = 2006 AND rating = 'PG-13';

