# Final-Project-Transforming-and-Analyzing-Data-with-SQL

## Project/Goals
In this project, I created an ecommerce database and imported tables from csv files to pgAdmin to clean, conduct quality assurance (QA) checks, and undergo data analyses using SQL. 

## Process

### 1. Load Data

My first step for this project involved importing data from csv to pgAdmin. I began with the allsessions file to create Table 1. When doing this I set the variable types based on a quick review of the data in the csv format, and made changes to the variable types as I encountered issues loading the data if it was incompatible, or later in the project as I realized a need for formatting as other data types. I tried to prioritize data types that use the fewest bytes, but sometimes chose to be more liberal in case I expected other data types to be needed for a given variable.

#### Table 1: allsessions

``` SQL
CREATE TABLE all_sessions.temp
(
    fullVisitorId bigint,   
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
    currencyCode char,
    itemQuantity int,
    itemRevenue	bigint,
    transactionRevenue bigint,
    transactionId bigint,
    pageTitle varchar,
    searchKeyword varchar,
    pagePathLevel1 varchar,
    eCommerceAction_type smallint,
    eCommerceAction_step smallint,
    eCommerceAction_option smallint
);

```

When I tried to load the table I encountered an error using the **COPY** function in SQL. After consulting stackoverflow and various other sources, I realized I needed to use Terminal/SQL shell to transfer the data from the csv file. In the terminal I connected to my database and then copied the csv data in to my table with all of the colums in the correct order

``` psql
psql -U postgres -d ecommerce

\copy allsessions
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/all_sessions.csv'
DELIMITER ','
CSV HEADER;
```
I then repeated this process with the remaining tables.

#### Table 2: analytics

``` SQL
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
```

#### Table 3: products

``` SQL
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
```

#### Table 4: sales_SKU

``` SQL
CREATE TABLE sales_sku
(
    productSKU varchar,
	total_ordered smallint
);

-- used psql
\copy sales_sku
FROM '/Users/marissa/Documents/LightHouse/Projects/Transforming-Data-SQL-Project/sql final project data_updated/sales_by_SKU.csv'
DELIMITER ','
CSV HEADER;
```

#### Table 5: salesreport

``` SQL
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
```

### 2. Clean Data

After loading the data, I prepared to clean the data. This was an interative process as I soon realized a lot of discrepancies in the data as I progressed through the tables. My first goal was to ensure data is formatted properly where **NULL**s were (or should have been) present before trying to fill in the nulls using data from other tables. I eventually realized that the data is too unreliable to accurately fill in nulls (see Quality Assurance section for elaboration).

After identifying nulls I attempted to clean data in anticipation for possible research questions (e.g. final category of product viewed by the user). 

### allsessions

To achieve this, I needed to first view the data (columns and rows) to understand what the data is saying, identify potential issues, and decide on what steps to take to try and produce some sort of analysis that may interest the client.

```SQL
SELECT *
FROM allsessions;
```

Upon noticing that some of the data had inputs of "not set/not available" I tried to identify where they were present and replaced them with **NULL** for consistency. My concern was that if I did not replace the data it would lead to unreliable counts and interpretations of the data. I was cautious in case some of the varchar variables also include strings with "not" in them that should not be replaced.

```SQL 
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
```
In doing this, I also noticed a lot of **NULL**s in the city column.

My next step was to convert the date variable as I had incorrectly set the date type when I created the table.

```SQL
SELECT *
FROM allsessions;

-- note: overthought this variable when creating table; see "Challenges"

SELECT CAST(date AS DATE)
FROM allsessions;

UPDATE allsessions
SET date = CAST(date AS DATE);
```
Finally, I began reviewing the data to look for patterns of error or interest that may be useful in answering the provided assignment questions or for developing my own questions for the client.

```SQL 
SELECT fullvisitorid, visitid
FROM allsessions
ORDER BY fullvisitorid ASC,
	visitid ASC;

-- not sure what to do yet with product SKU as there are a few without letters preceding them, but will wait to see how they are formatted in other tables

SELECT DISTINCT productsku
FROM allsessions
ORDER BY productsku ASC;
```
I wanted to see if I could find a different way to format the productvariant and product categories columns as I thought there may be something of interest to find by aggregating data pertaining to these columns and wanted to develop consistency to do so.

```SQL
SELECT DISTINCT productvariant
FROM allsessions;

SELECT DISTINCT v2productcategory
FROM allsessions;

UPDATE allsessions 
SET v2productcategory = NULL
WHERE v2productcategory LIKE '%{escCatTitle}';
```

I reviewed the data multiple times before deciding on my preferred way to rename the categories. I prioritized the last category along the pipeline of Home/category1/.../categoryn and looked for the most consistent way to rename the categories. Some data points were inputted into the **LIKE** statement without the "/", suggesting that it may not identify the final category, but those cases were based on my assessment of what the final category was referring to based on the initial *v2productcategory* identified with the **DISTINCT** function.

```SQL
-- created temporary table to prevent undesirable changes before reviewing and then implementing

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
```

Next, I converted the product price as it was too large, suggesting it had too many trailing 0s attached to it. You will notice that I decided against the **FLOAT** data type only because I was worried that the prices would be inappropriately modified (particularly the larger prices) and decided it was worth the effort of rounding the final values when I use the prices in my analyses. 

At the time, I did not notice the *transactionrevenue* and *totaltransactionrevenue* columns had large values as well. When I did, I was hesitant to modify them because I had no understanding of what determined the transaction revenue (and how it differed from the total transaction revenue) and did not want to permanently change these columns. There did not seem to be a pattern between transaction revenue and product price for each entry and I had no reliable way of verifying the other products ordered in the transaction and the number of units sold (see QA for more details). Conversely, I could roughly spot-check a few of the product names and their corresponding prices to confirm that dividing the values by 1,000,000 was the right choice for the type of product.

```SQL
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
ALTER COLUMN productprice TYPE DECIMAL(20,2);

UPDATE allsessions
SET productprice = productprice / 1000000.00;
```
A $0 product price did not seem to be correct as there were a few so I converted them to **NULL**. At the time this seemed to be correct, but in retrospect this may have indicated a sale of "buy one get one free", but there is no way to guarantee this without contacting the client.

```SQL
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
```

### analytics

The above process was repeated with the analytics table...

```SQL
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
```

### products

...and the products table.

```SQL
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

SELECT DISTINCT productsku 
FROM products
WHERE productsku LIKE '%31023';
```
The SKU identified in allsessions was not a variation of other SKUs in the salesreport or products tables. I decided to investigate this more to see what products were associated with this SKU and a few others that did not start with letters (unlike the majority of the SKUs)

```SQL
SELECT DISTINCT productsku, v2productname 
FROM allsessions
ORDER BY productsku ASC;

-- identified these products as having unusual SKUs
-- "YouTube Unstructured Cap - Charcoal"
-- "Sports Water Bottle"
-- "24oz USA Made Aluminum Bottle"
```

In doing this session, I noticed leading spaces in the *name* columns that I wanted to remove from the products table.

```SQL
SELECT
	TRIM(LEADING ' ' FROM name) AS name
FROM products;

UPDATE products
SET name = TRIM(LEADING ' ' FROM name);

-- verifying that the productsku in the allsessions table that start with 10 are unusual SKUs and confirmed that they are not necessarily correct as there were no SKUs/product names in the products table  for these items

SELECT productsku, name
FROM products
WHERE name = 'YouTube Unstructured Cap - Charcoal'
	OR name = 'Sports Water Bottle'
	OR name = '24oz USA Made Aluminum Bottle';

-- returned no results

SELECT productsku, name
FROM products
WHERE name LIKE '%YouTube%';

-- returned no results
```
I left this as an issue to be aware of but did not want to modify the product SKU in allsessions as I had no way of verifying if I was missing information to explain why these products existed in allsessions but not the products table.

I continued with checking the data for errors in the formatting to clean.

```SQL
SELECT DISTINCT orderedquantity
FROM products
ORDER BY orderedquantity ASC; 

SELECT DISTINCT stocklevel
FROM products
ORDER BY stocklevel ASC; 
```

### sales_sku

```SQL
SELECT * FROM sales_sku;

SELECT DISTINCT productsku 
FROM sales_sku
ORDER BY productsku ASC;

SELECT DISTINCT total_ordered
FROM sales_sku
ORDER BY total_ordered ASC;
```

### salesreport

```SQL
SELECT * FROM salesreport;

SELECT DISTINCT productsku 
FROM salesreport
ORDER BY productsku ASC;

UPDATE salesreport
SET name = TRIM(LEADING ' ' FROM name);
```

Further cleaning happened during the next stage.

### Quality Assurance

Now I wanted to check for completeness and consistency of the data (within tables and between tables). I came back to quality assurance as I answered the project questions as new questions often lead to the identification of new issues with the data.

#### Checked for duplicates in productsku in products and sales tables

```SQL
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
```
No duplicates identified.

#### Contrasted counts of orders between tables to try and decipher meaning

```SQL
SELECT total_ordered, productsku
FROM sales_sku
ORDER BY total_ordered DESC;

SELECT total_ordered, productsku
FROM salesreport
ORDER BY total_ordered DESC;

SELECT orderedquantity, stocklevel, productsku
FROM products
ORDER BY orderedquantity DESC;
```

The sales tables and products table contained different information. I suspected that *total_ordered* referred to total number of purchased products by customers and the orderedquantity refers to the restocking of products for the client's supply.

I eventually realized the sales by SKU and sales report tables had overlapping value, and I found the sales by SKU table to be less informative as it had fewer columns. 

```SQL
SELECT productsku,
    productquantity,
    productprice,
    productrevenue
FROM allsessions
WHERE productquantity IS NOT NULL;
```
However, the *productquantity* in the allsessions table did not seem to correlate with the number of each product sold or the number in stock or the number of products ordered to restock (this query produces only 53 rows for all products ordered, and the value for product quantity was often 1). I suspect a high degree of missingness and/or I did not correctly deduce the purpose of this column.

In this query I also thought to see how these product columns may be related and I pulled the productprice and *productrevenue* as well. *productrevenue* was missing a lot of data. This may have been okay if the column accounted for many incomplete transactions from site viewers, but the *productrevenue* for the two rows that had data on it was not equal to the value of their productquantity * productprice. The discrepancy was close to a few cents, which may be from taxes, however this would need to be clarified. 

This inquiry also raises the question of how this differs from the transaction columns, though I suspect those columns come from some form of a grouped sum of all *productrevenue*s for each complete transaction. 

#### Checking for duplicate values in analytics and allsessions tables

I was concerned with duplicates in the products/sales tables as the counts and details for each SKU should be unique. However, I had come to realize that the analytics and allsessions tables may have captured page views by site users who did not necessarily make a purchase. Therefore, duplicates were not inherently an issue, though I did want to investigate the data further.

```SQL

SELECT a.fullvisitorid, a.time, a.date
FROM allsessions AS a
INNER JOIN allsessions AS b
USING(fullvisitorid)
WHERE a.date = b.date
ORDER BY a.fullvisitorid, a.date;
```
I used this query to confirm duplicates of fullvisitorid in allsessions may be due to multiple visits based on the date/time of visits. I continued to explore the relationship between these variables further

```SQL
SELECT a.fullvisitorid, a.date, a.v2productcategory, a.time
FROM allsessions AS a
JOIN (
    SELECT fullvisitorid, date, v2productcategory, time, COUNT(*) AS dupes
    FROM allsessions
    GROUP BY fullvisitorid, date, v2productcategory, time
    HAVING COUNT(*) > 1
) b on a.fullvisitorid = b.fullvisitorid AND a.date = b.date AND a.v2productcategory = b.v2productcategory AND a.time = b.time
ORDER BY a.fullvisitorid, a.date;
```

This query confirmed some visits had duplicates in the date/time using an INNER JOIN. However, I cannot confirm if these duplicates should be removed as I don't know a) how to interpret the time column (e.g. minutes/seconds? time spent on page? time of day?) and b) if the duplicates may have been created to capture certain actions occurring while on the webpage, such as adding an item to basket. Also, some of the times were 0, leading me to question the quality of the data in the time column and if I should make a permanent change to my data without having all of the information.

```SQL
SELECT a.fullvisitorid, a.visitid, a.date
FROM allsessions AS a
JOIN (
    SELECT fullvisitorid, visitid, date, productsku, COUNT(*) AS dupes
    FROM allsessions
    GROUP BY fullvisitorid, visitid, date, productsku
    HAVING COUNT(*) > 1
) b on a.fullvisitorid = b.fullvisitorid AND a.date = b.date AND a.visitid = b.visitid AND a.productsku = b.productsku;
```
I decided to isolate for a few visitids where there may be duplicates or the visitor accessed the page multiple times and looked at the same product in one day. I thought reviewing all of the data for these visits may be informative. And it was.

```SQL
SELECT *
FROM allsessions
WHERE visitid = 1495005901 OR 
	visitid = 1481233332 OR
	visitid = 1489797382 OR
	visitid = 1493605322 OR
	visitid = 1493909433
ORDER BY visitid;
```
Each of these results varied by time, suggesting they accessed the page multiple times (maybe they refreshed the page?), and one of the results suggested someone went from shopping to billing and payment during their visit. 

When I went back to the query and matched on all of the earlier variables and time, it did not seem to produce any duplicates in the allsessions table:
```SQL
SELECT a.fullvisitorid, a.visitid, a.date, a.time
FROM allsessions AS a
JOIN (
    SELECT fullvisitorid, visitid, date, time, productsku, COUNT(*) AS dupes
    FROM allsessions
    GROUP BY fullvisitorid, visitid, date, time, productsku
    HAVING COUNT(*) > 1
) b on a.fullvisitorid = b.fullvisitorid AND a.date = b.date AND a.visitid = b.visitid AND a.productsku = b.productsku AND a.time = b.time;
```
I moved on to QA for the analytics table:

```SQL
SELECT *
FROM analytics
WHERE units_sold > 0
ORDER BY visitid, visitnumber DESC;
```
This suggested that the analytics table may be more reliable to interpret all sales data (not a summative report) than the allsessions table (note: I also checked *itemquantity* in the allsessions table but it seemed as unreliable/empty as *productquantity*). At this point in time, I had still hoped to find a way to fill in the allsessions table using other datasets but I did not have faith in developing a reliable system. The analytics table does not have *productsku* despite having *units_sold*, and I don't think I could reliably connect the *units_sold* to the correct combination of *fullvisitorid* and *date* in the allsessions table as I only had the *unit_price* and multiple columns with unclear measures of time to link the two datasets.

So it was back to the drawing board with reviewing the data for QA.

```SQL
SELECT units_sold, visitid, visitnumber, price, RANK() OVER(PARTITION BY visitid ORDER BY visitnumber) AS Rank
FROM analytics
WHERE units_sold > 0
ORDER BY RANK DESC;
```
This made me notice that the duplicated data in the analytics table may capture when a purchase was made, with a separate row for each item purchased. 

I thought it would be easier to create a table (that I subsqeuently deleted) to play around with the data available for sold items in the analytics dataset. 

```SQL
SELECT SUM(units_sold)
FROM analytics;

CREATE TABLE analytics_sht AS (
	SELECT * 
	FROM analytics
	WHERE units_sold > 0;
)

SELECT * 
FROM analytics_sht;

SELECT fullvisitorid, COUNT(visitid), visitnumber, SUM(unit_price * units_sold) AS transactionrevenue
FROM analytics_sht
WHERE units_sold > 0
GROUP BY fullvisitorid, visitid, visitnumber
HAVING COUNT(visitid) > 1
ORDER BY fullvisitorid DESC;

SELECT fullvisitorid, visitid, visitnumber, SUM(unit_price * units_sold) AS transactionrevenue
FROM analytics_sht
WHERE visitid = '1493855521'
GROUP BY fullvisitorid, visitid, visitnumber
ORDER BY visitid DESC;

DROP TABLE analytics_sht;
```

I noticed that analytics & allsessions have duplicates in visitid, which were not an issue when the fullvisitorid matched, as this suggests that the visitor had multiple visits to the site, or perhaps viewed multiple pages, depending on how the visitid was created. However, I noticed some visitids corresponded to multiple fullvisitorids. At this point I decided not to attempt to remove duplicates without further clarity on the data. I also became hesitant to try to calculate transaction revenue using the analytics table as I could not verify consistency of the data.

#### Transaction Revenue

Confirmed transaction revenue likely had a high degree of missingness and I suspected did not correlate well with the salesreport as there were only five transactionrevenue entries (may need to be divided by 1,000,000).

```SQL

SELECT COUNT(transactionrevenue), transactionrevenue
FROM allsessions
GROUP BY transactionrevenue;

SELECT SUM(total_ordered), productsku
FROM salesreport
GROUP BY productsku;
```

#### Looking at analytics and allsessions to look for patterns

Used randomly selected ids.

```SQL
SELECT *
FROM analytics
WHERE visitid = '1493621769';
-- there is one entry for units_sold and revenue, and one entry with nothing in units_sold, otherwise all other information is identical

SELECT *
FROM analytics
WHERE fullvisitorid = '9999136945887060446' AND units_sold > 0;
-- two items were different purchased by this visitor (2 + 3 units each) during one site visit. 

SELECT *
FROM allsessions
WHERE fullvisitorid = '9999136945887060446' AND visitid = '1494262162';
-- I tried to identify the same activity in the allsessions table
-- the purchase did not exist in the allsessions table

SELECT *
FROM allsessions
WHERE fullvisitorid = '9999136945887060446' ;
-- the full visitorid did not exist in the allsessions table, making me question what the "all" in allsessions referred to

SELECT *
FROM allsessions
WHERE visitid = '1494262162';

SELECT *
FROM analytics
WHERE visitid = '1493621769' AND units_sold >0;
-- this visitid from earlier did correlate with the allsessions table and the purchases aligned, indicating the two tables probably SHOULD align in some capacity evidently do not

SELECT *
FROM analytics
WHERE visitid = '1493855521' AND units_sold >0;
-- I wanted to verify my understanding of analytics, and that this table should capture different visits, and shows different orders on different visits
```

#### Revisited cleaning when noticed some discrepancies in ecommerceaction columns during QA

```SQL
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
    
```

I then thought I should see if there may be missingness in the ecommerce action steps by looking for visits that reached/completed "Billing and Shipping", and has entries for products sold. All existing entries for products/items were collected, but fell short of the number of products that should have been sold according to the sales report. There is likely missing data in the ecommerce action step column and the product or item quantity columns.

```SQL
SELECT productquantity, itemquantity, ecommerceaction_step
FROM allsessions
WHERE ecommerceaction_step = 1;

SELECT productquantity, itemquantity, ecommerceaction_step
FROM allsessions
WHERE productquantity > 0 OR itemquantity > 0;
```

I also could not see any use in trying to fill in blanks based on transactions that made it to the "Checkout Confirmation" page as there was too much missingness. This page seemed to be a step after "Billing and Shipping" were completed so I thought it may be informative to filter for data referring to this.

```SQL
SELECT SUM(productquantity), productsku
FROM allsessions
WHERE pagetitle = 'Checkout Confirmation'
GROUP BY productsku
ORDER BY SUM(productquantity) DESC;
```

#### Finding and removing a single negative value in the analytics table for units_sold

In retrospect, as far as I know this negative value may have been a refund.

```SQL
SELECT SUM(units_sold)
FROM analytics;

SELECT DISTINCT(units_sold)
FROM analytics;

UPDATE analytics
SET units_sold = ABS(units_sold);
```

## Results

The data was not the most reliable so I do not fully trust that the answers provided to the questions in this assignment were the most accurate. They were answers I could come up with based on the information that was made available to me, and would be shared with the client with cautious interpretation due to missingness and errors. 

This made me realize just how valuable data dictionaries and client meetings are to inform all parties about the goals of the product. 

## Challenges 

The first challenge I faced involved permission errors when trying to load the data in pgadmin. I tried consulting numerous resources on how to provide pgadmin with access permissions to the csv files. I did not understand psql/shell well and could not figure out how to load the data using the \copy command. After doing more digging I learned that I had to use terminal, and then I learned that I had not installed psql. Once everything was installed I was able to load the data.

Creating the tables (particularly the first one for "all_sessions") was challenging because I was unfamiliar with the data and encountered errors for data types that I did not expect. It was an iterative process, but once I had the first table done the rest were much easier to prepare.

When I was creating the tables, please note that I was not sure if the date column would load properly as I set the type to date during creation, and I left it for cleaning (I realize now that I probably did not have to do that and could have saved myself some time).

Realized when trying to count instances where the currencycode is null, it does not get counted automatically the way that other variables with actual values do.

As indicated above, I had significant concern with removing duplicates and am not entirely sure there were any true duplicate entries as there seemed to be something different (albeit, possibly insignficant) in the remaining columns not used to identify duplicates.

I overdid it with the number of 0s in some of my values after converting them to decimals, but decided to just round the results (didnt feel like counting digits to set up the decimals )

Some product SKU were not in sales table, and it would have been nice to have them listed even if there were no sales. Since I question the quality of the data I have to question the missingness. 

Note that some of the products identified on viewed pages have a SKU that cannot be located in the products or sales report tables (e.g. product SKU of 10 31023). I had a lot of trouble trusting the SKU.

```SQL
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

--allsessions has multiple products with the same SKU, and multiple prices (may have changed names, e.g. "GGOEGFYQ016599")
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
```

## Future Goals

If I had more time and this was a real-world project, I would schedule a meeting with my manager and/or the client to clarify the information in this dataset in order to better answer any research questions and provide inferences based on the data.

One example of what I would bring up is how maybe we should drop all SKUs without letters because they have null prices and seem to be an error but would clarify first with clients--they could also represent something taken off shelf/discontinued.

```SQL
SELECT 
		DISTINCT(productsku), 
		v2productname,
		productprice
	FROM allsessions
	ORDER BY productsku;
 ```