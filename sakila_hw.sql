--  Display the first and last names of all actors from the table actor
SELECT actor.first_name AS "First Name", actor.last_name AS "Last Name"
from actor;

-- Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
select upper(concat(first_name , ' ', last_name)) as "Actor Name" 
from actor;

 -- You need to find the ID number, first name, and last name of an actor, 
 -- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "joe";

-- Find all actors whose last name contain the letters GEN:
select first_name, last_name
from actor
where last_name LIKE "%GEN%";

-- Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order:
select first_name, last_name
from actor
where last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country 
from country
WHERE country in ("Afghanistan", "Bangladesh", "China");

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description blob;

-- Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.
ALTER TABLE actor
drop column description;

-- List the last names of actors, as well as how many actors have that last name.
Select last_name, count(last_name) from actor
Group by last_name;

-- List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
Select last_name, count(last_name) from actor
Group by last_name
having count(last_name) > 1;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

-- Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

SET SQL_SAFE_UPDATES = 0;
update actor set first_name = "GROUCHO" where first_name = "HARPO";

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Use JOIN to display the first and last names, 
-- as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district
FROM staff 
INNER JOIN address ON staff.address_id = address.address_id;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM staff 
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date between '2005-08-01 00:00:00' AND '2005-08-31 00:00:00'
GROUP BY staff.staff_id;

-- List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
select film.title, count(film_actor.actor_id) as "Number of Actors"
from film
inner join film_actor ON film.film_id = film_actor.film_id
group by film.title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
Select film.title, count(inventory.film_id)
from film
join inventory ON film.film_id = inventory.film_id
where title = "Hunchback Impossible";

-- Using the tables payment and customer and the JOIN command,
--  list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount) as "Total Payment"
from customer
join payment ON customer.customer_id = payment.customer_id
group by customer.last_name
order by customer.last_name;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also 
-- soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English.
Select film.title
from film 
where (title like "K%" or title like "Q%") and (film.language_id in (select language.language_id 
																	from language where language.name = "English"));

-- Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name 
FROM actor
WHERE actor_id in
(
	select actor_id
    from film_actor
    where film_id in
(
	select film_id
    from film
    where title = 'Alone Trip'
  ) 
);

-- You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
from customer 
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id
where country.country = "Canada";

-- Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT film.title
from film
where film_id in
(
	select film_id
    from film_category
    where category_id in
(
	select category_id
    from category
    where name = "family"
  )
);			
-- same question using inner join
select film.title, category.name
from film
inner join film_category using (film_id)
inner join category using (category_id)
where category.name = "Family";		

-- Display the most frequently rented movies in descending order
select title, count(rental_id) as "Frequency"
from film
inner join inventory using (film_id)
inner join rental using (inventory_id)
group by title order by Frequency desc;

-- Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) as "Total Payment (in dollars)"
from store
inner join inventory using (store_id)
inner join rental using (inventory_id)
inner join payment using (rental_id)
group by store.store_id;

-- Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
inner join address using (address_id)
inner join city using (city_id)
inner join country using (country_id)
group by store.store_id;

-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount) 
from category 
inner join film_category using (category_id)
inner join inventory using (film_id)
inner join rental using (inventory_id)
inner join payment using (rental_id)
	group by category.name order by sum(payment.amount) desc
limit 5;

-- In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `TopFiveGenres` AS 
select category.name, sum(payment.amount) 
from category 
inner join film_category using (category_id)
inner join inventory using (film_id)
inner join rental using (inventory_id)
inner join payment using (rental_id)
	group by category.name order by sum(payment.amount) desc
limit 5;

-- How would you display the view that you created in 8a
select * from topfivegenres;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view `topfivegenres`;
