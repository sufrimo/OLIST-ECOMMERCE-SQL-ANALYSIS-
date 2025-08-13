CREATE TABLE customers_dataset (
	customer_id VARCHAR(50) PRIMARY KEY NOT NULL,
	customer_unique_id VARCHAR(50),
	customer_zip_code_prefix  VARCHAR(20),
	customer_city VARCHAR(50),
	customer_state VARCHAR(20)
);

SELECT customer_zip_code_prefix,customer_city,customer_state,  COUNT(*)
FROM customers_dataset
GROUP BY customer_zip_code_prefix,customer_city,customer_state
HAVING COUNT(*) >1;

SELECT * FROM customers_dataset;


--


CREATE TABLE geolocation_dataset (
    geolocation_zip_code_prefix VARCHAR(20),
    geolocation_lat DECIMAL(9,6),
    geolocation_lng DECIMAL(9,6),
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(10)
);

SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation_dataset
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) >1;

SELECT *FROM geolocation_dataset


--

--orders_item has composite key because 1 order_id can contain multiple item_id and therefore not unique
--contains detailed transactional data — each row is one item sold in an order
--granular fact (sales at item level)

CREATE TABLE order_items_dataset (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
	PRIMARY KEY (order_id, order_item_id)
);

SELECT * from order_items_dataset

ALTER TABLE order_items_dataset
ADD CONSTRAINT fk_order
FOREIGN KEY (order_id)
REFERENCES orders_dataset(order_id);

ALTER TABLE order_items_dataset
ADD CONSTRAINT fk_product
FOREIGN KEY (product_id)
REFERENCES products_dataset(product_id);

SELECT *FROM order_items_dataset;


--


CREATE TABLE payments_dataset (
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value NUMERIC(12, 2)
);

SELECT * FROM payments_dataset


--or create summary of payment 


CREATE VIEW order_payment_summary AS
SELECT
    order_id,
    SUM(payment_value) AS total_paid,
    COUNT(*) AS num_payments
FROM payments_dataset
GROUP BY order_id;


SELECT * FROM order_payment_summary


--


CREATE TABLE reviews_dataset (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

SELECT order_id, COUNT(*)
FROM reviews_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

ALTER TABLE reviews_dataset DROP CONSTRAINT reviews_dataset_pkey;
ALTER TABLE reviews_dataset ADD PRIMARY KEY (order_id);

SELECT *FROM reviews_dataset


--


--order dataset(dimension table or header:  Provides context to the fact table)

CREATE TABLE orders_dataset (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

SELECT o.order_id
FROM orders_dataset o
LEFT JOIN order_payment_summary p ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

--insert this order id into the order_payment_summary with 0 value (customer hasnt made payment)

INSERT INTO order_payment_summary (order_id, total_paid)
SELECT order_id, 0
FROM orders_dataset
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c'
  AND order_id NOT IN (SELECT order_id FROM order_payment_summary);

  SELECT * FROM order_payment_summary

ALTER TABLE orders_dataset
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers_dataset(customer_id);

ALTER TABLE orders_dataset
ADD CONSTRAINT fk_payment
FOREIGN KEY (order_id)
REFERENCES order_payment_summary (order_id);


ALTER TABLE orders_dataset
ADD CONSTRAINT fk_review
FOREIGN KEY (order_id)
REFERENCES reviews_dataset (order_id);


--


CREATE TABLE products_dataset(
 	product_id VARCHAR(50) PRIMARY KEY NOT NULL,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

SELECT * FROM products_dataset


--


CREATE TABLE sellers_dataset (
    seller_id VARCHAR(50) PRIMARY KEY NOT NULL,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

SELECT * FROM sellers_dataset


--


CREATE TABLE product_translation (
    product_category_name VARCHAR(100) PRIMARY KEY NOT NULL,
    product_category_name_english VARCHAR(100)
);

SELECT * FROM product_translation





-- 1. Total Orders

SELECT COUNT(*) AS Total_orders
FROM orders_dataset


-- 2. Check status of orders

SELECT 
	order_status,
	COUNT(*) AS status_count
FROM orders_dataset
GROUP BY order_status
ORDER BY status_count DESC;

-- 3. Total Revenue of all orders and delivered orders

SELECT 
	SUM(payment_value) as total_revenue
FROM payments_dataset;

-- 4. Total Revenue per order status and number of payment types
-- use VIEW table order_payment_summary

SELECT 
	o.order_status,
	COUNT(total_paid) AS num_payment,
	SUM(p.total_paid) as total_paid_orders
FROM orders_dataset o
JOIN order_payment_summary p ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY num_payment DESC ,total_paid_orders;

select * from orders_dataset

-- 5. Total Unique Customers
-- Each customer with unique id may have placed order multiple times but system assigned new customer id per transaction
		--customer_id>customer_unique_id
	
SELECT 
	COUNT (DISTINCT customer_unique_id) AS Total_Unique_Customers
FROM customers_dataset;

-- 6. Average Items per Order

SELECT 
	AVG(price)
FROM order_items_dataset;

-- 7. Average Review Score
select * from reviews_dataset

SELECT 
	AVG(review_score)
FROM reviews_dataset;

--8. Average Delivery Time (in days)

SELECT 
	AVG(
		EXTRACT(
			EPOCH FROM(order_delivered_customer_date - order_purchase_timestamp)/86400 )) AS Avg_delivery_time
FROM orders_dataset
WHERE order_status = 'delivered';

-- 9. Top 10 Cities by Number of Orders

SELECT
	customer_city,
	COUNT(customer_id) as number_of_orders,
	DENSE_RANK() OVER (ORDER BY COUNT(customer_id) DESC) as Rank_number
FROM customers_dataset
GROUP BY customer_city
LIMIT 10;


-- 10. Products Category by Quantity Sold

SELECT 
	count(o.order_id) as order_count,
	t.product_category_name_english
FROM order_items_dataset o
JOIN products_dataset p ON o.product_id = p.product_id
JOIN product_translation t ON p.product_category_name = t.product_category_name
GROUP BY 2
ORDER BY 1 DESC


-- 11. Top  Sellers by Revenue

SELECT 
	seller_id,
	SUM(price) as total_sales
FROM order_items_dataset
GROUP BY seller_id
ORDER BY total_sales DESC
LIMIT 1;

-- 12. On-Time Delivery Rate using subquery and CTE

--USING CTE

WITH OTDR as (
	SELECT
		COUNT(*) as total_delivery, 	
		COUNT(*) FILTER(
			WHERE order_delivered_customer_date <= order_estimated_delivery_date 
			) as ontime_delivery		
	FROM orders_dataset
)

SELECT
	ROUND(ontime_delivery::DECIMAL / total_delivery, 2) AS Ontime_delivery_rate
FROM OTDR

--USING SUBQUERY

SELECT 
	ROUND(ontime_delivery::DECIMAL / total_delivery, 2) AS Ontime_delivery_rate
FROM(
SELECT
		COUNT(*) as total_delivery, 	
		COUNT(*) FILTER(
			WHERE order_delivered_customer_date <= order_estimated_delivery_date 
			) as ontime_delivery		
	FROM orders_dataset)
	
	
-- 13. Return/Cancellation Rate

SELECT 
	ROUND(C.cancelled_orders::decimal /T.total_orders,2) as cancellation_percentage
	FROM
		(SELECT
				count(*) as cancelled_orders
			FROM orders_dataset
			WHERE order_status = 'canceled') as C, 
		(SELECT
				count(*) as total_orders
			FROM orders_dataset) as T

-- 14. Top Selling Product by Month

	--1st CTE: get sales per month by product category
	--2nd CTE: use 1st CTE to create ranking within month
	--final select: filter by sales with rank 1 only
	
WITH category_monthly_sales AS (
    SELECT
        TO_CHAR(d.order_purchase_timestamp, 'YYYY-MM') AS order_month,
        t.product_category_name_english,
        SUM(o.price)  AS total_sales
    FROM order_items_dataset o
    JOIN orders_dataset d ON o.order_id = d.order_id
    JOIN products_dataset p ON o.product_id = p.product_id
    JOIN product_translation t ON p.product_category_name = t.product_category_name
    GROUP BY order_month, t.product_category_name_english
),
ranked_categories AS (
    SELECT *,
           RANK() OVER (PARTITION BY order_month ORDER BY total_sales DESC) AS category_rank
    FROM category_monthly_sales
)
SELECT
    order_month,
    product_category_name_english,
    total_sales
FROM ranked_categories
WHERE category_rank = 1
ORDER BY order_month;


