# Quality Assurance

**What are your risk areas? Identify and describe them.**

**QA Process:**

Now I wanted to check for completeness and consistency of the data (within tables and between tables). I came back to quality assurance as I answered the project questions as new questions often lead to the identification of new issues with the data. Some of the major risk areas included difficulties identifying a unique primarykey, and high amounts of missingness.

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
