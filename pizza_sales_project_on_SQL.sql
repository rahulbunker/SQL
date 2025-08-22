create database pizzahut;
use pizzahut;
create table orders(order_id int not null,
order_date date not null ,
order_time time not null,
primary key(order_id));

create table order_details(order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

select * from pizzahut.pizzas;

select * from orders;

select * from pizza_types;

select * from order_details;

-- Basic 

-- 1. Retrieve the total number of orders placed.

select count(order_id) as total_number from orders;


-- 2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM((pizzas.price * order_details.quantity)),
            2) AS total_sales_or_revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest-priced pizza.

select max(price)  as hightest_price_pizza from pizzas; 

SELECT 
    a.price AS hightest_price_pizza, b.name
FROM
    pizzas AS a
        JOIN
    pizza_types AS b ON a.pizza_type_id = b.pizza_type_id
ORDER BY a.price DESC
LIMIT 1; 

select a.price , b.name from pizzas as a join pizza_types as b 
on  a.pizza_type_id = b.pizza_type_id where a.price = (select max(price) from pizzas);

-- 4. Identify the most common pizza size ordered.

select size,count(size) as total_order_no_ from pizzas group by size order by total_order_no_ desc limit 1  ;

select a.size ,  count(b.order_details_id) as order_count 
from pizzas as a join order_details as b 
on a.pizza_id = b.pizza_id
group by a.size order by order_count desc ;

-- 5. List the top 5 most ordered pizza types along with their quantities.

select a.name , sum(c.quantity) as total_quantiy from pizza_types as a join pizzas  as b on 
a.pizza_type_id = b.pizza_type_id 
join order_details as c on b.pizza_id = c.pizza_id
group by a.name 
order by total_quantiy   desc limit 5;


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

select a.category , sum(c.quantity) as total_quantiy from pizza_types as a join pizzas  as b on 
a.pizza_type_id = b.pizza_type_id 
join order_details as c on b.pizza_id = c.pizza_id
group by a.category
order by total_quantiy   desc;


-- INTERMEDIATE 

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

select a.category , sum(c.quantity) as total_quantiy from pizza_types as a join pizzas  as b on 
a.pizza_type_id = b.pizza_type_id 
join order_details as c on b.pizza_id = c.pizza_id
group by a.category
order by total_quantiy   desc;

-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count;


-- 8. Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types group by category ;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(qnty), 0) AS avg_count_perday
FROM
    (SELECT 
        b.order_date, SUM(a.quantity) AS qnty
    FROM
        order_details AS a
    JOIN orders AS b ON a.order_id = b.order_id
    GROUP BY order_date) AS order_count_perday;
    
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.


    select a.name , sum( c.quantity*b.price ) as revenue from pizza_types as a join pizzas as b
    on a.pizza_type_id = b.pizza_type_id join order_details as c on
    b.pizza_id = c.pizza_id
    group by name order by revenue desc limit 3 ;
    
-- Advanced:


-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select a.category , sum( c.quantity*b.price ) / (SELECT 
    ROUND(AVG(qnty)*100, 2) AS avg_count_perday
FROM
    (SELECT 
        b.order_date, SUM(a.quantity) AS qnty
    FROM
        order_details AS a
    JOIN orders AS b ON a.order_id = b.order_id
    GROUP BY order_date) AS order_count_perday)as revenue 


 from pizza_types as a join pizzas as b
    on a.pizza_type_id = b.pizza_type_id join order_details as c on
    b.pizza_id = c.pizza_id
    group by category order by revenue desc  ;
    
-- 12. Analyze the cumulative revenue generated over time.

select a.order_date , sum(c.price*b.quantity) as revenue  from orders as a join order_details as b on
a.order_id = b.order_id  join pizzas as c on c.pizza_id = b.pizza_id  group by order_date;


-- ans


select order_date , sum(revenue) over(order by order_date ) as cumulative_revenue from

(select a.order_date , sum(c.price*b.quantity) as revenue  from orders as a join order_details as b on
a.order_id = b.order_id  join pizzas as c on c.pizza_id = b.pizza_id  group by order_date) as sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select a.category , a.name ,sum(c.quantity*b.price) as revenue from pizza_types as a join pizzas as b on 
a.pizza_type_id = b.pizza_type_id join order_details as c 
on b.pizza_id= c.pizza_id group by category , name;

select category , name , revenue, rank() over(partition by category order by revenue desc ) as rankk from 
(select a.category , a.name ,sum(c.quantity*b.price) as revenue from pizza_types as a join pizzas as b on 
a.pizza_type_id = b.pizza_type_id join order_details as c 
on b.pizza_id= c.pizza_id group by category , name) as xyz;



-- ans 


select name ,revenue from (select category , name , revenue, rank() over(partition by category order by revenue desc ) as rankk from 
(select a.category , a.name ,sum(c.quantity*b.price) as revenue from pizza_types as a join pizzas as b on 
a.pizza_type_id = b.pizza_type_id join order_details as c 
on b.pizza_id= c.pizza_id group by category , name) as xyz)  as abc where rankk <= 3;









