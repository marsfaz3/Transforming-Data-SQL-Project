# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Project/Goals

## Process

### 1. Load Data


#### Table 1: allsessions
CREATE TABLE allsessions
(
    fullVisitorId varchar,   
    channelGrouping	varchar,
    time int,
    country varchar,
    city varchar,
    totalTransactionRevenue bigint,
    transactions smallint,
    timeOnSite smallint,
    pageviews smallint,
    sessionQualityDim smallint,
    date varchar,
    visitId	bigint,
    type varchar,
    productRefundAmount int,
    productQuantity int,
    productPrice bigint,
    productRevenue	bigint,
    productSKU varchar,
    v2ProductName varchar,
    v2ProductCategory varchar,
    productVariant varchar,
    currencyCode varchar,
    itemQuantity int,
    itemRevenue	bigint,
    transactionRevenue bigint,
    transactionId varchar,
    pageTitle varchar,
    searchKeyword varchar,
    pagePathLevel1 varchar,
    eCommerceAction_type smallint,
    eCommerceAction_step smallint,
    eCommerceAction_option varchar
);

-- used psql
psql -U postgres -d ecommerce
\copy allsessions
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/all_sessions.csv'
DELIMITER ','
CSV HEADER;

#### Table 2: analytics

CREATE TABLE analytics
(
    visitNumber	smallint,
	visitId	bigint,
	visitStartTime	bigint,
	date varchar,
	fullvisitorId varchar,
	userid varchar,
	channelGrouping	varchar,
	socialEngagementType varchar,
	units_sold int,
	pageviews smallint,
	timeonsite smallint,
	bounces smallint,
	revenue	bigint,
	unit_price bigint
);

-- used psql
\copy analytics
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/analytics.csv'
DELIMITER ','
CSV HEADER;

#### Table 3: products

CREATE TABLE products
(
    productSKU varchar,
	name varchar,
	orderedQuantity	smallint,
	stockLevel smallint,
	restockingLeadTime smallint,
	sentimentScore float,
	sentimentMagnitude float
);

-- used psql
\copy products
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/products.csv'
DELIMITER ','
CSV HEADER;

#### Table 4: sales_SKU

CREATE TABLE sales_SKU
(
    productSKU varchar,
	total_ordered smallint
);

-- used psql
\copy sales_SKU
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/sales_by_SKU.csv'
DELIMITER ','
CSV HEADER;

#### Table 5: salesreport

CREATE TABLE salesreport
(
    productSKU varchar,
	total_ordered smallint,
	name varchar,
	stockLevel smallint,
	restockingLeadTime smallint,
	sentimentScore float,
	sentimentMagnitude float,
	ratio float
);

-- used psql
\copy salesreport
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/sales_report.csv'
DELIMITER ','
CSV HEADER;

### 2. Clean Data

### a. Ensure data is complete (i.e. no blank or null values)

### b. Check that data is unique (i.e. no duplicate values), where applicable

### c. Verify data is consistent with what we expect (eg. a decimal between a certain range)

### allsessions

SELECT *
FROM allsessions;

#### data "not set/available" replaced with NULL

SELECT *
FROM allsessions
WHERE country LIKE '%not %'
	OR city LIKE '%not %'
	OR date LIKE '%not %'
	OR type LIKE '%not %'
	OR productsku LIKE '%not %'
	OR v2productname LIKE '%not %'
	OR v2productcategory LIKE '%not %'
	OR productvariant LIKE '%not %'
	OR currencycode LIKE '%not %'
	OR transactionid LIKE '%not %'
	OR pagetitle LIKE '%not %';

-- conducted one-by-one to assess variations in case accidentally replace the wrong string

SELECT DISTINCT city
FROM allsessions
WHERE city LIKE '%not %';

UPDATE allsessions
SET city = NULL
WHERE city LIKE '%not %';

SELECT DISTINCT country
FROM allsessions
WHERE country LIKE '%not %';

UPDATE allsessions
SET country = NULL
WHERE country LIKE '%not %';

SELECT DISTINCT v2productcategory
FROM allsessions
WHERE v2productcategory LIKE '%not %';

UPDATE allsessions
SET v2productcategory = NULL
WHERE v2productcategory LIKE '%not %';

SELECT DISTINCT productvariant
FROM allsessions
WHERE productvariant LIKE '%not %';

UPDATE allsessions
SET productvariant = NULL
WHERE productvariant LIKE '%not %';

#### convert date

SELECT *
FROM allsessions;

-- note: overthought this variable when creating table; see "Challenges"
SELECT CAST(date AS DATE)
FROM allsessions;


UPDATE allsessions
SET date = CAST(date AS DATE);

#### reviewing data

SELECT fullvisitorid, visitid
FROM allsessions
ORDER BY fullvisitorid ASC,
	visitid ASC;

-- not sure what to do yet with product SKU as there are a few without letters preceding them, but will 
-- wait to see how they are formatted in other tables

SELECT DISTINCT productsku
FROM allsessions
ORDER BY productsku ASC;

#### converting product categories

SELECT DISTINCT productvariant
FROM allsessions;

SELECT DISTINCT v2productcategory
FROM allsessions;

UPDATE allsessions 
SET v2productcategory = NULL
WHERE v2productcategory LIKE '%{escCatTitle}';

-- temporary table to prevent undesirable changes before reviewing

WITH allsessions2 AS (
SELECT 
	TRIM(LEADING 'Home/' FROM TRIM(TRAILING '/' FROM v2productcategory)) AS v2productcategory
FROM allsessions
)

SELECT
	DISTINCT CASE WHEN
		v2productcategory LIKE 'Drinkware%' OR v2productcategory LIKE '%/Drinkware' THEN 'Drinkware'
		WHEN v2productcategory LIKE '%/Housewares' THEN 'Housewares'
		WHEN v2productcategory LIKE '%/Pet' THEN 'Pet'
		WHEN v2productcategory LIKE '%/Sports & Fitness' THEN 'Sports & Fitness'
		WHEN v2productcategory LIKE '%/Stickers' THEN 'Stickers'
		WHEN v2productcategory LIKE '%/Headgear' THEN 'Headgear'
		WHEN v2productcategory LIKE '%Kid''s%' THEN 'Apparel_Kid''s'
		WHEN v2productcategory LIKE '%/Men''s%' THEN 'Apparel_Men''s'
		WHEN v2productcategory LIKE '%/Women''s%' THEN 'Apparel_Women''s'
		WHEN v2productcategory LIKE '%Bags%' THEN 'Bags'
		WHEN v2productcategory LIKE '%Bottles%' THEN 'Drinkware'
		WHEN v2productcategory LIKE '%Sale%' THEN 'Sale'
		WHEN v2productcategory LIKE '%/Fun' THEN 'Fun'
		WHEN v2productcategory LIKE '%/Audio' OR v2productcategory LIKE '%/Electronics Accessories' OR v2productcategory LIKE '%/Power' OR v2productcategory LIKE '%/Flashlights'THEN 'Electronics'
		WHEN v2productcategory LIKE '%Nest%' THEN 'Nest-USA'
		WHEN v2productcategory LIKE '%Office%' THEN 'Office'
		WHEN v2productcategory LIKE '%/Android' THEN 'Brands_Android'
		WHEN v2productcategory LIKE '%/Google' THEN 'Brands_Google'
		WHEN v2productcategory LIKE '%/Waze' THEN 'Brands_Waze'
		WHEN v2productcategory LIKE '%YouTube' THEN 'Brands_YouTube'
		WHEN v2productcategory LIKE 'Shop by Brand' THEN 'Brands'
		WHEN v2productcategory LIKE 'adgear' THEN 'Headgear'
		WHEN v2productcategory LIKE 'usewares' THEN 'Housewares'
		ELSE v2productcategory
		END
FROM allsessions2;


UPDATE allsessions
SET v2productcategory = TRIM(LEADING 'Home/' FROM TRIM(TRAILING '/' FROM v2productcategory));

UPDATE allsessions
SET v2productcategory = 
CASE WHEN
		v2productcategory LIKE 'Drinkware%' OR v2productcategory LIKE '%/Drinkware' THEN 'Drinkware'
		WHEN v2productcategory LIKE '%/Housewares' THEN 'Housewares'
		WHEN v2productcategory LIKE '%/Pet' THEN 'Pet'
		WHEN v2productcategory LIKE '%/Sports & Fitness' THEN 'Sports & Fitness'
		WHEN v2productcategory LIKE '%/Stickers' THEN 'Stickers'
		WHEN v2productcategory LIKE '%/Headgear' THEN 'Headgear'
		WHEN v2productcategory LIKE '%Kid''s%' THEN 'Apparel_Kid''s'
		WHEN v2productcategory LIKE '%/Men''s%' THEN 'Apparel_Men''s'
		WHEN v2productcategory LIKE '%/Women''s%' THEN 'Apparel_Women''s'
		WHEN v2productcategory LIKE '%Bags%' THEN 'Bags'
		WHEN v2productcategory LIKE '%Bottles%' THEN 'Drinkware'
		WHEN v2productcategory LIKE '%Sale%' THEN 'Sale'
		WHEN v2productcategory LIKE '%/Fun' THEN 'Fun'
		WHEN v2productcategory LIKE '%/Audio' OR v2productcategory LIKE '%/Electronics Accessories' OR v2productcategory LIKE '%/Power' OR v2productcategory LIKE '%/Flashlights'THEN 'Electronics'
		WHEN v2productcategory LIKE '%Nest%' THEN 'Nest-USA'
		WHEN v2productcategory LIKE '%Office%' THEN 'Office'
		WHEN v2productcategory LIKE '%/Android' THEN 'Brands_Android'
		WHEN v2productcategory LIKE '%/Google' THEN 'Brands_Google'
		WHEN v2productcategory LIKE '%/Waze' THEN 'Brands_Waze'
		WHEN v2productcategory LIKE '%YouTube' THEN 'Brands_YouTube'
		WHEN v2productcategory LIKE 'Shop by Brand' THEN 'Brands'
		WHEN v2productcategory LIKE 'adgear' THEN 'Headgear'
		WHEN v2productcategory LIKE 'usewares' THEN 'Housewares'
		ELSE v2productcategory
		END;


-- converting product prices

SELECT DISTINCT productprice
FROM allsessions
ORDER BY productprice ASC;

SELECT DISTINCT productprice, v2productname
FROM allsessions
GRoUP BY productprice, v2productname
ORDER BY productprice ASC;


SELECT productprice::FLOAT / 1000000
FROM allsessions
ORDER BY productprice ASC;

ALTER TABLE allsessions 
--ALTER COLUMN productprice TYPE FLOAT;
ALTER COLUMN productprice TYPE DECIMAL(20,2);

UPDATE allsessions
SET productprice = productprice / 1000000.00;

SELECT 
	DISTINCT CASE WHEN productprice = 0 THEN NULL
	ELSE productprice
	END
FROM allsessions
ORDER BY productprice ASC;

UPDATE allsessions
SET productprice =
	CASE WHEN productprice = 0 THEN NULL
	ELSE productprice
	END;


### analytics

SELECT * FROM analytics

UPDATE analytics
SET date = CAST(date AS DATE);

SELECT DISTINCT channelgrouping FROM analytics;
SELECT DISTINCT channelgrouping FROM allsessions;
SELECT DISTINCT socialengagementtype FROM analytics;

ALTER TABLE analytics 
ALTER COLUMN unit_price TYPE DECIMAL(20,2);

UPDATE analytics
SET unit_price = unit_price / 1000000.00;

UPDATE analytics
SET unit_price =
	CASE WHEN unit_price = 0 THEN NULL
	ELSE unit_price
	END;

### products

SELECT * FROM products;

SELECT DISTINCT productsku 
FROM products
ORDER BY productsku ASC;

SELECT DISTINCT productsku 
FROM allsessions
ORDER BY productsku ASC;

-- pulled a SKU of 10 31023 from the list that seemed off to confirm if it may be a variation of another SKU

SELECT DISTINCT productsku 
FROM salesreport
WHERE productsku LIKE '%31023';

SELECT DISTINCT productsku, v2productname 
FROM allsessions
ORDER BY productsku ASC;

-- "YouTube Unstructured Cap - Charcoal"
-- "Sports Water Bottle"
-- "24oz USA Made Aluminum Bottle"

SELECT
	TRIM(LEADING ' ' FROM name) AS name
FROM products;

UPDATE products
SET name = TRIM(LEADING ' ' FROM name);

-- verifying that the productsku in the allsessions table that start with 10 are not incorrect SKUs (and confirmed)
-- that they are not necessarily incorrect

SELECT productsku, name
FROM products
WHERE name = 'YouTube Unstructured Cap - Charcoal'
	OR name = 'Sports Water Bottle'
	OR name = '24oz USA Made Aluminum Bottle';

SELECT productsku, name
FROM products
WHERE name LIKE '%YouTube%';

SELECT DISTINCT orderedquantity
FROM products
ORDER BY orderedquantity ASC; 

SELECT DISTINCT stocklevel
FROM products
ORDER BY stocklevel ASC; 

### sales_sku

SELECT * FROM sales_sku;

SELECT DISTINCT productsku 
FROM sales_sku
ORDER BY productsku ASC;

SELECT DISTINCT total_ordered
FROM sales_sku
ORDER BY total_ordered ASC;

### salesreport

SELECT * FROM salesreport;

SELECT DISTINCT productsku 
FROM salesreport
ORDER BY productsku ASC;

UPDATE salesreport
SET name = TRIM(LEADING ' ' FROM name);

--*** QA **********

SELECT COUNT(productsku), productsku
FROM salesreport
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

SELECT COUNT(productsku), productsku
FROM products
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

SELECT COUNT(productsku), productsku
FROM sales_sku
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

SELECT total_ordered, productsku
FROM sales_sku
ORDER BY total_ordered DESC;

SELECT total_ordered, productsku
FROM salesreport
ORDER BY total_ordered DESC;

SELECT orderedquantity, stocklevel, productsku
FROM products
ORDER BY orderedquantity DESC;

SELECT productsku,
productquantity,
productprice,
productrevenue
FROM allsessions
WHERE productquantity IS NOT NULL;

-- checking for duplicate values (***analytics & allsessions have duplicates in visitid)

SELECT a.fullvisitorid, a.time, a.date
FROM allsessions AS a
INNER JOIN allsessions AS b
USING(fullvisitorid)
WHERE a.date = b.date
ORDER BY a.fullvisitorid, a.date;

select a.fullvisitorid, a.date, a.v2productcategory, a.time
from allsessions AS a
join (
    select fullvisitorid, date, v2productcategory, time, COUNT(*) AS dupes
    from allsessions
    group by fullvisitorid, date, v2productcategory, time
    having count(*) > 1
) b on a.fullvisitorid = b.fullvisitorid and a.date = b.date AND a.v2productcategory = b.v2productcategory AND a.time = b.time
ORDER BY a.fullvisitorid, a.date;


select a.fullvisitorid, a.visitid, a.date
from allsessions AS a
join (
    select fullvisitorid, visitid, date, productsku, COUNT(*) AS dupes
    from allsessions
    group by fullvisitorid, visitid, date, productsku
    having count(*) > 1
) b on a.fullvisitorid = b.fullvisitorid and a.date = b.date AND a.visitid = b.visitid AND a.productsku = b.productsku
ORDER BY a.fullvisitorid, a.date;


SELECT a.fullvisitorid, a.visitid, a.date, a.time
FROM allsessions AS a
JOIN (
    SELECT fullvisitorid, visitid, date, time, productsku, COUNT(*) AS dupes
    FROM allsessions
    GROUP BY fullvisitorid, visitid, date, time, productsku
    HAVING COUNT(*) > 1
) b on a.fullvisitorid = b.fullvisitorid AND a.date = b.date AND a.visitid = b.visitid AND a.productsku = b.productsku AND a.time = b.time;

SELECT *
FROM allsessions
WHERE visitid = 1495005901 OR 
	visitid = 1481233332 OR
	visitid = 1489797382 OR
	visitid = 1493605322 OR
	visitid = 1493909433
ORDER BY visitid;

SELECT *
FROM analytics
WHERE units_sold > 0
ORDER BY visitid, visitnumber DESC;

SELECT units_sold, visitid, visitnumber, RANK() OVER(PARTITION BY visitid ORDER BY visitnumber) AS Rank
FROM analytics
WHERE units_sold > 0
ORDER BY RANK DESC;

SELECT units_sold, visitid, visitnumber, unit_price, RANK() OVER(PARTITION BY visitid ORDER BY visitnumber) AS Rank
FROM analytics
WHERE units_sold > 0
ORDER BY RANK DESC;

SELECT SUM(units_sold)
FROM analytics;

SELECT a.fullvisitorid, a.visitid, a.date, a.visitnumber, a.units_sold, a.unit_price
FROM analytics AS a
JOIN (
    SELECT fullvisitorid, visitid, visitnumber, COUNT(*) AS dupes
    FROM analytics
    GROUP BY fullvisitorid, visitid, visitnumber
    HAVING COUNT(*) > 1
	ORDER BY visitid
) b ON a.fullvisitorid = b.fullvisitorid AND a.visitid = b.visitid AND a.visitnumber = b.visitnumber
ORDER BY a.visitid;

CREATE TABLE analytics_sht AS (
	SELECT * 
	FROM analytics
	WHERE units_sold > 0
)

SELECT * 
FROM analytics_sht;

SELECT fullvisitorid, visitid, visitnumber, SUM(unit_price * units_sold) AS transactionrevenue
FROM analytics_sht
GROUP BY fullvisitorid, visitid, visitnumber
HAVING visitid = '1493855521'
ORDER BY visitid DESC;


SELECT fullvisitorid, COUNT(visitid), visitnumber, SUM(unit_price * units_sold) AS transactionrevenue
FROM analytics_sht
WHERE units_sold > 0
GROUP BY fullvisitorid, visitid, visitnumber
HAVING COUNT(visitid) > 1
ORDER BY fullvisitorid DESC;

DROP TABLE analytics_sht;

SELECT COUNT(transactionrevenue), transactionrevenue
FROM allsessions
GROUP BY transactionrevenue;

SELECT SUM(total_ordered), productsku
FROM salesreport
GROUP BY productsku;

SELECT *
FROM analytics
WHERE visitid = '1493621769';

SELECT *
FROM analytics
WHERE fullvisitorid = '9999136945887060446' AND units_sold > 0;

SELECT *
FROM allsessions
WHERE fullvisitorid = '9999136945887060446' AND visitid = '1494262162';

SELECT *
FROM allsessions
WHERE fullvisitorid = '9999136945887060446' ;

SELECT *
FROM allsessions
WHERE visitid = '1494262162';

SELECT *
FROM analytics
WHERE visitid = '1493621769' AND units_sold >0;

SELECT *
FROM analytics
WHERE visitid = '1493855521' AND units_sold >0;








---

SELECT *
FROM allsessions
WHERE ecommerceaction_step = 2;

SELECT DISTINCT(ecommerceaction_step), ecommerceaction_option
FROM allsessions;

UPDATE allsessions
SET ecommerceaction_option =
	CASE WHEN ecommerceaction_step = 1
	THEN 'Billing and Shipping' ELSE
	ecommerceaction_option
	END;

SELECT COUNT(productsku), productsku
FROM allsessions
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

SELECT COUNT(productsku), productsku
FROM allsessions
WHERE productsku = 'GGOEGDHC074099'
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

SELECT COUNT(productsku), productsku
FROM allsessions
WHERE ecommerceaction_step = 3
GROUP BY productsku
ORDER BY COUNT(productsku) DESC;

-- I assume product revenue is incorrect and will delete it

SELECT SUM(productquantity), productsku
FROM allsessions
GROUP BY productsku
HAVING SUM(productquantity) > 0
ORDER BY SUM(productquantity) DESC;

SELECT SUM(productquantity), productsku
FROM allsessions
WHERE pagetitle = 'Checkout Confirmation'
GROUP BY productsku
ORDER BY SUM(productquantity) DESC;


SELECT SUM(units_sold)
FROM analytics;

SELECT DISTINCT(units_sold)
FROM analytics;

UPDATE analytics
SET units_sold = ABS(units_sold);



WITH test AS (
	SELECT 
)


SELECT SUM(productquantity), productsku
FROM allsessions
WHERE pagetitle = 'Checkout Confirmation'
GROUP BY productsku
ORDER BY SUM(productquantity) DESC;

## Results
(fill in what you discovered this data could tell you and how you used the data to answer those questions)

***create column for ordered quantity < stocklevel for restocking!

## Challenges 
(discuss challenges you faced in the project)

The first challenge I faced involved permission errors when trying to load the data in pgadmin. I tried
consulting numerous resources on how to provide pgadmin with access permissions to the csv files. I did not 
understand psql/shell well and could not figure out how to load the data using the \copy command. After
doing more digging I learned that I had to use terminal, and then I learned that I had not installed psql.
Once everything was installed I was able to load the data.

Creating the tables (particularly the first one for "all_sessions") was challenging because I was unfamiliar with
the data and encountered errors for data types that I did not expect. It was an iterative process, but once I 
had the first table done the rest were much easier to prepare.

When I was creating the tables, please note that I was not sure if the date column would load properly as I 
set the type to date during creation, and I left it for cleaning (I realize now that I probably didnt have to do that
and could have saved myself some time).

Realized when trying to count instances where the currencycode is null, it does not get counted automatically
the way that other variables with actual values do.

Concern with removing duplicates ***
Overdid it with the number of 0s in some of my counts but just round the results (didnt feel like counting digits)
**some productsku not in sales table


Note that some of the products identified on viewed pages have a SKU that cannot be located in the products
or sales report tables (e.g. product SKU of 10 31023)

SELECT productsku
FROM salesreport
WHERE productsku = '10 31023';

WITH productnames AS (
SELECT DISTINCT(productsku), v2productname
FROM allsessions
GROUP BY productsku, v2productname
ORDER BY productsku;
)

SELECT DISTINCT p.productsku, p.name
FROM products AS p
GrOUP BY p.productsku, p.name
ORDER BY productsku;

***allsessions has multiple products with the same SKU, and multiple prices (may have changed names "GGOEGFYQ016599")
SELECT 
	v2productname,
	productprice
FROM allsessions
WHERE productsku = 'GGOEGFYQ016599'
GROUP BY v2productname, productprice
	
SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice
	FROM allsessions
	ORDER BY v2productname

## Future Goals
(what would you do if you had more time?)

Drop SKUs without letters at the beginning bc have null prices and seem to be an  error but would clarify first with clients--could represent something such as taken off shelf
SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice
	FROM allsessions
	ORDER BY v2productname

Sales? (or discount codes?)
SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice,
		date,
		currencycode
	FROM allsessions
	ORDER BY v2productname, date

Clean product names for discrepancies