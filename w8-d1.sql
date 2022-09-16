use sakila;



-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from film;
select * from inventory;

	-- subquery:
select film_id from film where title = 'Hunchback Impossible';

	-- query:
select count(inventory_id) from inventory
where film_id = (select film_id from film where title = 'Hunchback Impossible');



-- 2. List all films whose length is longer than the average of all the films.
select film_id, title, length from film
where length > (select avg(length) from film);



-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor;
select * from film_actor;
select * from film;

	-- subquery1:
select film_id from film
where title = "Alone Trip";

	-- subquery2:
select actor_id from film_actor
where film_id = (select film_id from film where title = "Alone Trip");

	-- query:
select concat(first_name, ' ', last_name) as 'Alone Trip Cast' from actor
where actor_id in (
	select actor_id from (
		select actor_id from film_actor
		where film_id = (select film_id from film where title = "Alone Trip")
        )sub1
        );
							
                            
                            
-- 4. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as family films.
select * from film;
select * from film_category;
select * from category;

	-- subquery1:
select category_id from category where name = 'Family';

	-- subquery2:
select film_id from film_category 
where category_id = (select category_id from category where name = 'Family');

	-- query:
select film_id, title from film
where film_id in (
	select film_id from(
		select film_id from film_category 
		where category_id = (select category_id from category where name = 'Family')
		)sub1
        );
        


-- 5. Get name and email from customers from Canada using subqueries. Do the same with 
-- joins. Note that to create a join, you will have to identify the correct tables 
-- with their primary keys and foreign keys, that will help you get the relevant information.
select * from customer;
select * from address;
select * from city;
select * from country;

	-- subquery1
select country_id from country where country = 'Canada';

	-- subquery2
select city_id from city 
where country_id = (select country_id from country where country = 'Canada');

	-- subquery3
select address_id from address
where city_id in (
	select city_id from(
		select city_id from city 
		where country_id = (select country_id from country where country = 'Canada')
        )sub1
        );

	-- query:
select customer_id, concat(first_name, ' ', last_name) as 'Customers from Canada', email from customer
where address_id in (
	select address_id from(
		select address_id from address
			where city_id in (
				select city_id from(
					select city_id from city 
					where country_id = (select country_id from country where country = 'Canada')
					)sub1
					)
				)sub2
				);

	-- with joins:
    select customer_id, concat(first_name, ' ', last_name) as 'Customers from Canada', email from customer
    inner join address using(address_id)
    inner join city using(city_id)
    inner join country using(country_id)
    where country = 'Canada';
    


-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined 
-- as the actor that has acted in the most number of films. First you will have to 
-- find the most prolific actor and then use that actor_id to find the different films 
-- that he/she starred.
select * from actor;
select * from film_actor;
select * from film;

	-- subquery1
select actor_id, count(film_id) as count, rank() over(order by count(film_id) desc) as ranking from film_actor
group by actor_id;

	-- subquery2
select actor_id from (
	select actor_id, count(film_id) as count, rank() over(order by count(film_id) desc) as ranking from film_actor
	group by actor_id
    ) sub1
where ranking = 1;

	-- subquery3
select film_id from film_actor
where actor_id = (
	select actor_id from (
		select actor_id, count(film_id) as count, rank() over(order by count(film_id) desc) as ranking from film_actor
		group by actor_id
		) sub1
	where ranking = 1
    );

	-- query:
select film_id, title from film
where film_id in(
	select film_id from(
		select film_id from film_actor
		where actor_id = (
			select actor_id from (
				select actor_id, count(film_id) as count, rank() over(order by count(film_id) desc) as ranking from film_actor
				group by actor_id
				)sub1
			where ranking = 1)
		)sub2
        );



-- 7. Films rented by most profitable customer. You can use the customer table and 
-- payment table to find the most profitable customer ie the customer that has 
-- made the largest sum of payments.
select * from payment;
select * from customer;
select * from rental;
select * from inventory;
select * from film;

	-- subquery1
select customer_id, sum(amount), rank() over(order by sum(amount) desc) as ranking from payment
group by customer_id;

	-- subquery2
select customer_id from (
	select customer_id, sum(amount), rank() over(order by sum(amount) desc) as ranking from payment
	group by customer_id
    )sub1
where ranking = 1;	

	-- subquery3
select inventory_id from rental
where customer_id in (
	select customer_id from (
		select customer_id from (
			select customer_id, sum(amount), rank() over(order by sum(amount) desc) as ranking from payment
			group by customer_id
			)sub1
		where ranking = 1
        )sub2
	);
    
	-- subquery4
select film_id from inventory
where inventory_id in (
	select inventory_id from (
		select inventory_id from rental
		where customer_id in (
			select customer_id from (
				select customer_id from (
					select customer_id, sum(amount), rank() over(order by sum(amount) desc) as ranking from payment
					group by customer_id
					)sub1
				where ranking = 1
				)sub2
			)
		)sub3
	);
    
	-- query
select title from film
where film_id in (
	select film_id from (
		select film_id from inventory
		where inventory_id in (
			select inventory_id from (
				select inventory_id from rental
				where customer_id in (
					select customer_id from (
						select customer_id from (
							select customer_id, sum(amount), rank() over(order by sum(amount) desc) as ranking from payment
							group by customer_id
							)sub1
						where ranking = 1
						)sub2
					)
				)sub3
			)
    )sub4
    );
    
    
    
-- 8. Get the client_id and the total_amount_spent of those clients who spent more 
-- than the average of the total_amount spent by each client.
select * from payment;

	-- subquery1
select customer_id, avg(amount) as average_per_client from payment
group by customer_id;

	-- subquery2
select avg(average_per_client) as global_average from (
	select customer_id, avg(amount) as average_per_client from payment
	group by customer_id
    )sub1;

	-- query
select customer_id, avg(amount) as average_per_client from payment
group by customer_id
having average_per_client > (
	select avg(average_per_client) as global_average from (
		select customer_id, avg(amount) as average_per_client from payment
		group by customer_id
		)sub1
    );





