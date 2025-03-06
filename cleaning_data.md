# Cleaning Data

**What issues will you address by cleaning the data?**

Cleaning the data can help to make it more consistent and readable to improve data analysis abilities and data quality. I often scanned the data for areas of interest that could matter for data analysis to decide what to prioritize cleaning and to plan how to go about it.

**Queries:**

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
