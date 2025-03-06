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

Further cleaning happened during the next stage.

### 3. Quality Assurance

Now I wanted to check for completeness and consistency of the data (within tables and between tables). I came back to quality assurance as I answered the project questions as new questions often lead to the identification of new issues with the data.

#### Checked for duplicates in productsku in products and sales tables

#### Contrasted counts of orders between tables to try and decipher meaning

#### Checking for duplicate values in analytics and allsessions tables

#### Transaction Revenue

#### Looking at analytics and allsessions to look for patterns

#### Revisited cleaning when noticed some discrepancies during QA

#### Finding and removing a single negative value in the analytics table for units_sold

### 4. Begin analysis

With an iterative process, I began the data analysis, but returned to perform QA/checks throughout.

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