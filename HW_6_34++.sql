--- Q1 ---
SELECT o.user_id, sum(product_price*quantity) AS total_spent
FROM ORDERs_sql_project o
LEFT JOIN ORDER_ITEMS_SQL_PROJECT OI
ON oi.order_id = o.ORDER_ID 
LEFT JOIN products_sql_project p
ON p.product_id = oi.product_id
GROUP BY 1
ORDER BY 2 desc;  

--- Q2 ---
SELECT user_id, order_date, store_order_id AS order_id
FROM STORE_ORDERS SO
WHERE user_id IS NOT null
UNION ALL
SELECT user_id, order_date, order_id 
FROM orders_sql_project
WHERE user_id IS NOT NULL
ORDER BY user_id, order_date, order_id;

--- Q3 ---
 SELECT product_id FROM ORDER_ITEMS_SQL_PROJECT
 INTERSECT 
 SELECT product_id FROM store_order_items
 ORDER BY 1;




--- Q4 ---
SELECT user_id FROM ORDERS_SQL_PROJECT
WHERE order_id in(SELECT order_id 
FROM order_items_sql_project 
WHERE quantity >2)
intersect
SELECT user_id FROM store_ORDERS
WHERE store_order_id in(SELECT store_order_id 
FROM store_order_items 
WHERE quantity >2)
and user_id IS NOT NULL
ORDER BY 1;

--- Q5 ---
SELECT avg(total_check) AS avg_check
FROM (SELECT oi.order_id, sum(product_price*quantity) AS total_check
FROM order_items_sql_project oi
LEFT JOIN PAYMENTS_SQL_PROJECT P
ON oi.order_id=p.order_id
LEFT JOIN PRODUCTS_SQL_PROJECT Pr
ON pr.product_id = oi.product_id
WHERE payment_status LIKE 'Оплачено'
GROUP BY 1) order_check;

--- Q6 ---
WITH products_quantity_stores AS (
SELECT order_id, quantity, 'online' AS store_type
FROM order_items_sql_project oi
UNION all
SELECT store_order_id AS order_id, quantity, 'offline' AS store_type
FROM store_order_items)
SELECT store_type, sum(quantity) AS total_quantity, 
count(DISTINCT order_id) AS total_orders
FROM products_quantity_stores
GROUP BY 1
ORDER BY 1,2,3;

--- Q7 ---
WITH users_products as(
SELECT user_id, product_id 
FROM order_items_sql_project oi
LEFT JOIN orders_sql_project o
ON oi.order_id = o.order_id
UNION ALL
SELECT user_id, product_id 
FROM store_order_items soi
LEFT JOIN store_orders so
ON soi.store_order_id = so.store_order_id)
SELECT product_id, count(DISTINCT user_id) AS users
FROM users_products
WHERE user_id IS NOT null
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

--- Q8 ---
SELECT sum(quantity * product_price)/count(DISTINCT oi.order_id) AS avg_check,
'online' AS shop_type
FROM order_items_sql_project oi
LEFT JOIN orders_sql_project o
ON oi.order_id = o.order_id
LEFT JOIN PRODUCTS_SQL_PROJECT P
ON p.product_id = oi.product_id
UNION all
SELECT sum(quantity * product_price)/count(DISTINCT soi.store_order_id) AS avg_check,
'offline' AS shop_type
FROM store_order_items soi
LEFT JOIN store_orders so
ON soi.store_order_id = so.store_order_id
LEFT JOIN PRODUCTS_SQL_PROJECT P
ON p.product_id = soi.product_id
ORDER BY 1;

--- Q9 ---
WITH all_orders AS(
SELECT user_id, product_id
FROM order_items_sql_project oi
LEFT JOIN orders_sql_project o
ON oi.order_id = o.order_id)
SELECT DISTINCT user_id
FROM all_orders a
left JOIN products_sql_project p
ON a.product_id = p.product_id
WHERE product_price > (
SELECT avg(product_price) AS avg_product_price
FROM products_sql_project
WHERE product_id IN( 
SELECT DISTINCT soi.product_id 
FROM store_order_items soi)
) AND user_id IS NOT NULL 
ORDER BY user_id;

--- Q10 ---
WITH all_orders AS
	(SELECT oi.order_id, order_date, user_id, product_id, quantity
FROM ORDERS_SQL_PROJECT O
inner JOIN order_items_sql_project oi
ON o.order_id = oi.order_id
UNION ALL
SELECT soi.store_order_id AS order_id, order_date, user_id, product_id, quantity
FROM store_ORDERS sO
inner JOIN store_order_items soi
ON so.store_order_id = soi.store_order_id),
	avg_check as(
	SELECT sum(product_price*quantity) / count(DISTINCT order_id) AS avg_check
FROM all_orders a
LEFT JOIN products_sql_project p
ON a.product_id = p.product_id),
	order_above_average as(
	SELECT order_id, date_trunc('month',order_date)::date AS order_month, user_id, sum(p.product_price*quantity) AS ORDER_check
FROM all_orders a
LEFT JOIN products_sql_project p
ON a.product_id = p.PRODUCT_ID
GROUP BY 1,2,3
having sum(p.product_price*quantity) > (SELECT * FROM avg_check)
)
	SELECT order_month, count(DISTINCT user_id)
	FROM order_above_average
	WHERE user_id IS NOT NULL
	GROUP BY 1
	ORDER BY 1;

