--- Q1 ---
SELECT user_city, count(*) AS unique_users
FROM project.users_sql_project
GROUP BY 1
ORDER BY 2 desc;

--- Q2 ---
SELECT order_id 
FROM project.order_items_sql_project
GROUP BY order_id 
ORDER BY sum(quantity) DESC
LIMIT 1;

--- Q3 ---
SELECT COUNT(DISTINCT ORDER_id)
FROM project.payments_sql_project 
WHERE PAYMENT_METHOD IN ('Картка', 'Банківський переказ') 
AND payment_status NOT LIKE 'Відхилено';

--- Q4 ---
SELECT user_id, count(DISTINCT order_id) AS total_orders
FROM project.orders_sql_project
GROUP BY 1
HAVING count(DISTINCT order_id) >= 5
ORDER BY total_orders DESC;

--- Q5 ---
SELECT sum(quantity) AS total_quantity,
count(DISTINCT order_id) AS unique_orders
FROM project.order_items_sql_project 
WHERE product_id IN (11, 23);

--- Q6 ---
SELECT tracking_number, 
coalesce(delivery_date::text, 'в роботі') as delivery_date
FROM project.shipments_sql_project;

--- Q7 ---
SELECT 
CASE 
WHEN user_age >=45 THEN 'старший вік'
WHEN user_age >=25 THEN 'середній вік'
ELSE 'молоді'
END AS age_category,
count(*)
FROM project.users_sql_project
GROUP BY 1;

--- Q8 ---
SELECT user_city,  count(DISTINCT loyalty_status) AS loyalty_all
FROM project.users_sql_project
GROUP BY 1
HAVING count(DISTINCT loyalty_status)>=3
ORDER BY 2;

--- Q9 ---
SELECT *
FROM project.users_sql_project
WHERE user_email LIKE '%@gmail.com';

--- Q10 ---
SELECT courier, avg(delivery_date-shipment_date) AS avg_days
FROM project.shipments_sql_project
GROUP BY 1
ORDER BY 2;
