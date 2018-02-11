-- SQL Homework

USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS actor_name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know 
-- only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows 
-- by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(50)
AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
-- SELECT CAST(middle_name AS BINARY) FROM actor AS middle_name;
ALTER TABLE actor CHANGE middle_name middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS Count
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS Count
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table 
-- as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO 
--  was the correct name after all! In a single query, if the first name of the actor is 
--  currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
-- as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE 
-- THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'MUCHO GROUCHO'
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district, address.postal_code
FROM staff LEFT JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT staff_id, SUM(p.amount) AS total_amount, MAX(p.payment_date) As date
FROM staff s LEFT JOIN payment p
USING (staff_id)
WHERE p.payment_date LIKE '2005-05%'
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use inner join.
SELECT f.title, COUNT(a.actor_id) AS number_of_actors
FROM film f INNER JOIN film_actor a
USING (film_id)
GROUP BY film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, 
(
SELECT COUNT(inventory_id)
FROM inventory
WHERE film.film_id = inventory.film_id
) AS quantity
FROM film
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_amount
FROM customer c LEFT JOIN payment p
USING (customer_id)
GROUP BY customer_id
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM language;
SELECT * FROM film;
SELECT title
FROM film
WHERE language_id IN 
(
  SELECT language_id
  FROM language
  WHERE name = 'English'
)
AND title LIKE 'K%' 
OR title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film
  WHERE title = 'Alone Trip'
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email 
-- addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email
FROM customer c 
JOIN address a
ON c.address_id = a.address_id
JOIN city y
ON a.city_id = y.city_id
JOIN country r
ON y.country_id = r.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
 SELECT film_id 
 FROM film_category
 WHERE category_id IN
 (
  SELECT category_id
  FROM category
  WHERE name = 'Family'
 )
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id) AS frequency_rented
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY frequency_rented DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS total_revenue
FROM store s
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, y.city, r.country
FROM store s
JOIN address a ON a.address_id = s.address_id
JOIN city y ON y.city_id = a.city_id
JOIN country r ON r.country_id = y.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name
FROM category c
JOIN film_category f ON f.category_id = c.category_id
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category c
JOIN film_category f ON f.category_id = c.category_id
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;
