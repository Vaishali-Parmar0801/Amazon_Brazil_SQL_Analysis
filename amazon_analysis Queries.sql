-- CREATING DATABASE
		CREATE DATABASE amazon_analysis;

-- CREATING SCHEMA
		CREATE SCHEMA amazon_brazil;

-- 1: CREATING TABLE customers

		CREATE TABLE amazon_brazil.customers(
		customer_id VARCHAR(50) PRIMARY KEY,
		customer_unique_id VARCHAR(50),
		customer_zip_code_prefix INT);

		SELECT * FROM amazon_brazil.customers;

-- 2: CREATING TABLE orders

		CREATE TABLE amazon_brazil.orders(
		order_id VARCHAR(50) PRIMARY KEY,
		customer_id VARCHAR(50),
		order_status VARCHAR(50),
		order_purchase_timestamp TIMESTAMP,
		order_approved_at TIMESTAMP,
		order_delivered_carrier_date TIMESTAMP,
		order_delivered_customer_date TIMESTAMP,
		order_estimated_delivery_date TIMESTAMP);

		SELECT * FROM amazon_brazil.orders;

-- 3: CREATING TABLE payments

		CREATE TABLE amazon_brazil.payments(
		order_id VARCHAR(50),
		payment_sequential INT,
		payment_type VARCHAR(30),
		payment_installments INT,
		payment_value DECIMAL(10,2));

		SELECT * FROM amazon_brazil.payments;

-- 4: CREATING TABLE seller

		CREATE TABLE amazon_brazil.seller(
		seller_id VARCHAR(50) PRIMARY KEY,
		seller_zip_code_prefix INT);

		SELECT * FROM amazon_brazil.seller;

-- 5: CREATING TABLE order_items

		CREATE TABLE amazon_brazil.order_items(
		order_id VARCHAR(50) REFERENCES orders(order_id),
		order_item_id INT,
		product_id VARCHAR(50),
		seller_id VARCHAR(50),
		shipping_limit_date TIMESTAMP,
		price DECIMAL(10,2),
		freight_value DECIMAL(10,2));

		SELECT * FROM amazon_brazil.order_items;

-- 6: CREATING TABLE product

		CREATE TABLE amazon_brazil.product(
		product_id VARCHAR(50) PRIMARY KEY,
		product_category_name VARCHAR(50),
		product_name_lenght INT,
		product_description_lenght INT,
		product_photos_qty INT,	
		product_weight_g INT,
		product_length_cm INT,
		product_height_cm INT,
		product_width_cm INT);

		SELECT * FROM amazon_brazil.product;

-- ANALYSIS I
-- Q1: Round average payment value per payment type, sorted ascending

		SELECT * FROM amazon_brazil.payments;
		
		SELECT payment_type, 
		ROUND(AVG(payment_value),0) AS rounded_avg_payment
		FROM amazon_brazil.payments
		WHERE payment_type <> 'not_defined'
		GROUP BY payment_type
		ORDER BY rounded_avg_payment ASC;

-- Q2: Calculate percentage share of total orders per payment type, sorted descending

		SELECT * FROM amazon_brazil.payments;

		SELECT payment_type,
		ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM amazon_brazil.payments),1)
		AS percentage_orders
		FROM amazon_brazil.payments
		GROUP BY payment_type
		ORDER BY percentage_orders DESC;

-- Q3: Find products priced 100-500 BRL with 'Smart' in name, sorted by price descending
	
		SELECT DISTINCT p.product_id,oi.price
		FROM amazon_brazil.product p
		JOIN amazon_brazil.order_items oi
		ON p.product_id=oi.product_id
		WHERE oi.price BETWEEN 100 AND 500
		AND p.product_category_name ILIKE '%smart%'
		ORDER BY oi.price DESC;
		
-- Q4: Find top 3 months with highest total sales value, rounded to nearest integer

		SELECT 
		EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
		ROUND(SUM(oi.price)) AS total_sales
		FROM amazon_brazil.orders o
		JOIN amazon_brazil.order_items oi
			ON o.order_id=oi.order_id
		GROUP BY MONTH
		ORDER BY total_sales DESC
		LIMIT 3;

-- Q5: Find product categories where max and min price difference exceeds 500 BRL

		SELECT p.product_category_name,
			ROUND(MAX(oi.price) - MIN(oi.price))AS price_difference
		FROM amazon_brazil.product p
		JOIN amazon_brazil.order_items oi
			ON p.product_id=oi.product_id
		GROUP BY p.product_category_name
		HAVING (MAX(oi.price) - MIN(oi.price))>500
		ORDER BY price_difference DESC;

-- Q6: Identify payment types with least variance in transaction amounts by standard deviation

		SELECT payment_type,
		ROUND(STDDEV(payment_value) ::NUMERIC,2) AS std_deviation
		FROM amazon_brazil.payments
		GROUP BY payment_type
		ORDER BY std_deviation ASC;
    
-- Q7: Retrieve products where category name is missing or contains only a single character

		SELECT product_id,product_category_name
		FROM amazon_brazil.product
		WHERE product_category_name IS NULL 
			OR LENGTH (product_category_name)=1
		ORDER BY product_id ;
		
-- Analysis II 
-- Q1: Segment orders into Low/Medium/High, count each payment type within segments, sort by count descending

		SELECT 
		CASE
			WHEN payment_value < 200
				THEN 'low(<200)'
			WHEN payment_value BETWEEN 200 AND 1000 
				THEN 'medium(200-1000)'
			WHEN payment_value > 1000 
				THEN 'high( > 1000)'
		END
		AS order_value_segment,
		payment_type,
		COUNT(*) AS count
		FROM amazon_brazil.payments
		GROUP BY order_value_segment,payment_type
		ORDER BY count DESC;

--Q2: Calculate min, max, avg price per category, sorted by avg price descending

		SELECT p.product_category_name,
			ROUND(MIN(oi.price)) AS min_price,
			ROUND(MAX(oi.price)) AS max_price,
			ROUND(AVG(oi.price)) AS avg_price
		FROM amazon_brazil.product p
		JOIN amazon_brazil.order_items oi
			ON p.product_id=oi.product_id
		GROUP BY p.product_category_name
		ORDER BY avg_price DESC;

--Q3: customers with more than one order, and display their customer unique IDs along with the total number of orders they have placed.

		SELECT 
		c.customer_unique_id,
    	COUNT(o.order_id) AS total_orders
		FROM amazon_brazil.customers c
		JOIN amazon_brazil.orders o 
    		ON c.customer_id = o.customer_id
		GROUP BY c.customer_unique_id
		HAVING COUNT(o.order_id) > 1
		ORDER BY total_orders DESC;

--Q4: Label customers: New = 1 order, Returning = 2–4 orders, Loyal = more than 4 orders

		CREATE TEMP TABLE customer_order_counts AS
		SELECT
		c.customer_unique_id,
			COUNT (o.order_id) AS total_orders
		FROM amazon_brazil.customers c
		JOIN amazon_brazil.orders o
			ON c.customer_id=o.customer_id
		GROUP BY c.customer_unique_id;

		SELECT * FROM customer_order_counts;

		SELECT customer_unique_id,
		CASE 
			WHEN total_orders=1		THEN 'New'
			WHEN total_orders BETWEEN 2 AND 4		THEN 'Returning'
			WHEN total_orders > 4			THEN 'Loyal'
		END AS customer_type
		FROM customer_order_counts
		ORDER BY total_orders DESC;
		
--Q5: Which product categories make the most revenue? Show top 5.

		SELECT p.product_category_name,
			ROUND(SUM(oi.price)) AS total_revenue
		FROM amazon_brazil.product p
		JOIN amazon_brazil.order_items oi
			ON p.product_id=oi.product_id
		GROUP BY product_category_name
		ORDER BY total_revenue 
		LIMIT 5;

-- ANALYSIS III
--Q1: Calculate total sales for Spring, Summer, Autumn, Winter

		SELECT 
			CASE
				WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (3,4,5) THEN 'spring'
				WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (6,7,8) THEN 'summer'
				WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (9,10,11) THEN 'autumn'
				WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp ) IN (1,2,12) THEN 'winter'
			END AS season,
			oi.price
		FROM amazon_brazil.orders o
		JOIN amazon_brazil.order_items oi
			ON oi.order_id=o.order_id
		LIMIT 5;

		SELECT season,
		 ROUND(SUM(price))AS total_sales
		FROM(
			SELECT
				CASE
					WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (3,4,5) THEN 'spring'
					WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (6,7,8) THEN 'summer'
					WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp )IN (9,10,11) THEN 'autumn'
					WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp ) IN (1,2,12) THEN 'winter'
				END AS season,
				oi.price
			FROM amazon_brazil.orders o
			JOIN amazon_brazil.order_items oi
			ON oi.order_id=o.order_id) AS seasonal_data
			GROUP BY season
			ORDER BY total_Sales DESC;
		 
--Q2 :Find products whose total quantity sold is above the overall average.

		SELECT product_id,
		COUNT(*)AS total_quantity_sold
		FROM amazon_brazil.order_items	
		GROUP BY product_id
		HAVING count(*)>(

			SELECT AVG(total_qty)
			FROM (SELECT product_id,
			COUNT(*) AS total_qty
			FROM amazon_brazil.order_items
			GROUP BY product_id)
			AS qty_per_product)
			ORDER BY total_quantity_sold DESC;

--Q3: Total revenue each month in 2018 — for graph export

		SELECT order_purchase_timestamp
		FROM amazon_brazil.orders
		WHERE EXTRACT (YEAR FROM order_purchase_timestamp) = 2018
		LIMIT 3;

		SELECT 
			EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
			ROUND(SUM(oi.price)) AS total_revenue
		FROM amazon_brazil.orders o
		JOIN amazon_brazil.order_items oi
			ON o.order_id=oi.order_id
		WHERE EXTRACT (YEAR FROM order_purchase_timestamp) = 2018
		GROUP BY month
		ORDER BY total_revenue ASC;

--Q4: Occasional = 1–2 orders, Regular = 3–5 orders, Loyal = more than 5.

		WITH orders_counts AS (
		SELECT
			c.customer_unique_id,
			COUNT(o.order_id) AS total_orders,
				CASE
				WHEN COUNT(o.order_id) <= 2 THEN 'occational'
				WHEN COUNT(o.order_id) BETWEEN 3 AND 5 THEN 'regular'
				WHEN COUNT(o.order_id) >=5 THEN 'loyal'
			END AS customer_type
			
			FROM amazon_brazil.customers c
			JOIN amazon_brazil.orders o
				ON c.customer_id=o.customer_id 
			GROUP BY customer_unique_id
			
			)
			
		SELECT 
			 customer_type,
			COUNT (*) AS count
		FROM orders_counts
		GROUP BY customer_type
		ORDER BY count DESC;	

--Q5: Rank customers based on average order value — show top 20
		WITH customer_avg AS(
			SELECT
				o.customer_id,
				ROUND(AVG(oi.price)) AS avg_order_value
			FROM amazon_brazil.orders o
			JOIN amazon_brazil.order_items oi
				ON o.order_id=oi.order_id
			GROUP BY customer_id
		)
		SELECT 
			customer_id,
			avg_order_value,
			RANK()OVER (ORDER BY avg_order_value DESC) AS customer_rank
		FROM customer_avg
		ORDER BY customer_rank
		LIMIT 20;


--Q6: Calculate running total of sales for each product month by month
		
		WITH monthly_sales AS (
	    SELECT 
	        oi.product_id,
	        DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
	        SUM(oi.price) AS monthly_sales
	    FROM amazon_brazil.orders o
	    JOIN amazon_brazil.order_items oi 
			ON o.order_id = oi.order_id
	    GROUP BY oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp)
	)
		SELECT 
		    product_id,
		    sale_month,
		    ROUND(SUM(monthly_sales) OVER (
		        PARTITION BY product_id   
		        ORDER BY sale_month)) AS total_sales
		FROM monthly_sales
		ORDER BY product_id, sale_month;
				
--Q7: Month-over-Month Sales Growth by Payment Type

		WITH total_sale AS
		(
		SELECT p.payment_type, 
		EXTRACT (MONTH FROM o.order_purchase_timestamp) AS sale_month,
		ROUND(SUM(oi.price)) AS monthly_total
		FROM amazon_brazil.orders o
		JOIN amazon_brazil.order_items oi
		ON o.order_id = oi.order_id
		JOIN amazon_brazil.payments p
		ON o.order_id = p.order_id
		WHERE EXTRACT (YEAR FROM o.order_purchase_timestamp) = 2018
		GROUP BY p.payment_type, sale_month
		)
		SELECT payment_type, sale_month, monthly_total,
		CASE
		WHEN LAG(monthly_total) OVER () = 0 THEN NULL
		else
		round((monthly_total - LAG(monthly_total) OVER())/LAG(monthly_total) OVER() * 100)
		END AS monthly_change
		FROM total_sale;
