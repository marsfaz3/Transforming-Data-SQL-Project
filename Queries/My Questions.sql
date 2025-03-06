**Question 1: What are the top 5 most viewed products?**

SQL Queries:

SELECT COUNT(v2productname), v2productname
FROM allsessions
GROUP BY v2productname
ORDER BY COUNT(v2productname) DESC
LIMIT 5;

Answer:
"Google Men's 100% Cotton Short Sleeve Hero Tee White"
"22 oz YouTube Bottle Infuser"
"YouTube Twill Cap"
"YouTube Custom Decals"
"YouTube Men's Short Sleeve Hero Tee Black"

**Question 2: Which products were too low on stock at the time of ordering and require restocking to complete the orders? Was enough stock ordered? (see products table)**

SQL Queries:

WITH p_stock AS (
SELECT 
	productsku, 
	name,
	total_ordered,
	stocklevel,
	(CASE WHEN total_ordered > stocklevel 
		THEN 'out of stock' ELSE 'in stock'
		END) AS stockstatus
	FROM salesreport
)


SELECT 
	s.productsku, 
	s.name,
	s.total_ordered,
	s.stocklevel,
	p.orderedquantity,
	(s.total_ordered - s.stocklevel - p.orderedquantity) AS add_order
FROM products AS p
JOIN p_stock AS s
USING (productsku)
WHERE 
	s.stockstatus = 'out of stock' AND
	(s.total_ordered - s.stocklevel - p.orderedquantity) > 0
GROUP BY 
	s.productsku, 
	s.name,
	s.total_ordered,
	s.stocklevel,
	p.orderedquantity
ORDER BY s.total_ordered;

/*
SELECT COUNT(*)
FROM p_stock
WHERE stockstatus = 'out of stock'
*/

Answer:
"Android Infant Short Sleeve Tee Pewter" (need to add another three units to the ordered quantity to meet the ordered needs)

**Question 3: What are the price(s) of the top 10 most purchased products? What issue did you identify with the data?**

SQL Queries:

SELECT COUNT(DISTINCT productsku)
FROM salesreport

SELECT COUNT(productsku)
FROM salesreport

-- no duplicate SKUs identified in the salesreport

WITH pricing AS (
	SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice
	FROM allsessions
	ORDER BY v2productname
)

SELECT
	s.productsku,
	s.name,
	s.total_ordered,
	p.productprice
FROM salesreport s
JOIN pricing p
USING (productsku)
WHERE s.total_ordered IS NOT NULL
ORDER BY s.total_ordered DESC
LIMIT 10;


WITH pricing AS (
	SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice
	FROM allsessions
	ORDER BY v2productname
)


SELECT
	s.productsku,
	s.name,
	s.total_ordered,
	p.productprice,
	DENSE_RANK() OVER(ORDER BY s.total_ordered DESC) AS Rank
FROM salesreport s
JOIN pricing p
USING (productsku)
WHERE s.total_ordered IS NOT NULL;


SELECT 
	v2productname,
	productprice
FROM allsessions
WHERE productsku = 'GGOEGOAQ012899'
GROUP BY v2productname, productprice

SELECT 
	v2productname,
	productprice
FROM allsessions
WHERE productsku = 'GGOEGFYQ016599'
GROUP BY v2productname, productprice
	

Answer:
"Ballpoint LED Light Pen"
"Ballpoint LED Light Pen"
"17oz Stainless Steel Sport Bottle"
"17oz Stainless Steel Sport Bottle"
"Leatherette Journal"
"Leatherette Journal"
"Spiral Journal with Pen"
"Foam Can and Bottle Cooler"
"Foam Can and Bottle Cooler"
"Foam Can and Bottle Cooler"
2.00
2.50
15.19
18.99
8.79
10.99
9.99
1.99
1.99
1.59

**Question 4: How many customers made it to the checkout confirmation page?**

SQL Queries:

SELECT COUNT(*)
FROM allsessions
WHERE pagetitle IS NULL;

SELECT 
	COUNT(DISTINCT fullvisitorid)
FROM allsessions
WHERE pagetitle LIKE 'Checkout Confirmation';

Answer:

9 

There is one missing data point however

**Question 5: Are there any descrepancies in the stocklevel and SKU of products in the sales report and products tables? **

SQL Queries:

WITH comb_table AS (
SELECT
	p.productsku AS sku_from_products,
	s.productsku AS sku_from_sales,
	p.name,
	p.stocklevel AS stock_from_products,
	s.stocklevel AS stock_from_sales
FROM products p
FULL OUTER JOIN salesreport s
USING(productsku)
)

SELECT COUNT(
	CASE WHEN stock_from_products <> stock_from_sales THEN 'Error'
	ELSE NULL
	END)
FROM comb_table
WHERE stock_from_sales IS NOT NULL;

-- 638 stock of products were not included/not sold in the salesreport
SELECT COUNT(stock_from_products)
FROM comb_table
WHERE stock_from_sales IS NULL 

-- 638 sku of products were not included/not sold in the salesreport
SELECT COUNT(sku_from_products)
FROM comb_table
WHERE sku_from_sales IS NULL

-- no sales table that are not in the products table 
SELECT *
FROM comb_table
WHERE sku_from_products IS NULL;

WITH comb_table AS (
SELECT
	p.productsku AS sku_from_products,
	s.productsku AS sku_from_sales,
	p.name,
	p.stocklevel AS stock_from_products,
	s.stocklevel AS stock_from_sales
FROM products p
LEFT OUTER JOIN salesreport s
USING (productsku)
WHERE s.productsku IS NOT NULL
)

SELECT COUNT(
	CASE WHEN stock_from_products <> stock_from_sales THEN 'Error'
	ELSE NULL
	END)
FROM comb_table
WHERE stock_from_sales IS NOT NULL;

Answer:

There are no discrepancies in stocklevel, but there are in sku. 638 products were not sold from the products in the
product list at the time of the sales report.