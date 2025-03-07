Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**

SQL Queries:
```SQL
SELECT city, country, SUM(transactionrevenue/1000000) AS tot_transactionrevenue
FROM allsessions
GROUP BY city, country
HAVING SUM(transactionrevenue/1000000) > 0
ORDER BY SUM(transactionrevenue/1000000) DESC;

SELECT city, country, SUM(totaltransactionrevenue/1000000) AS tot_transactionrevenue
FROM allsessions
GROUP BY city, country
HAVING SUM(totaltransactionrevenue/1000000) > 0
ORDER BY SUM(totaltransactionrevenue/1000000) DESC;
```

Answer:  
Note that I assumed revenue also needed to divide by 1,000,000. The data source, validity, and differentiation between transactionrevenue v. totaltransactionrevenue are unclear. Many cities are also null.

Using transactionrevenue, only two data points were inputted: (#1)"United States", (no city) and (#2) "United States", "Sunnyvale".

Using totaltransactionrevenue, the top cities/countries are:  
(no city), "United States"  
"San Francisco", "United States"  
"Sunnyvale", "United States"  
"Atlanta", "United States"  
"Palo Alto", "United States"  
"Tel Aviv-Yafo", "Israel"  
"New York", "United States"  
"Mountain View", "United States"  
"Los Angeles", "United States"  
"Chicago", "United States"  

**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:
```SQL
SELECT city, country, AVG(itemquantity) AS numberofitems
FROM allsessions
GROUP BY city, country
HAVING AVG(itemquantity) IS NOT NULL
ORDER BY AVG(itemquantity) DESC;

SELECT COUNT(itemquantity)
FROM allsessions
WHERE itemquantity IS NOT NULL;

SELECT city, country, ROUND(AVG(productquantity),0) AS numberofproducts
FROM allsessions
GROUP BY city, country
HAVING AVG(productquantity) IS NOT NULL
ORDER BY AVG(productquantity) DESC;
```

Answer:  
Unclear how to determine the number of products as there are no entries for itemquantity.

Instead, using productquantity (which shows great discrepancy from the number of units sold when summed together; see QA) we can identify the average number of products sold (maximum is 10) based on the data. This information is unable to be gathered by any other table/combination of joins available to us. For this question and the following two below I assumed productquantity meant products sold but I was doubtful it is accurate.

**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:

```SQL
SELECT COUNT(v2productcategory), v2productcategory, city, country
FROM allsessions
WHERE v2productcategory IS NOT NULL AND transactions > 0
GROUP BY v2productcategory, city, country
ORDER BY COUNT(v2productcategory) DESC;

SELECT COUNT(v2productcategory), v2productcategory, city, country
FROM allsessions
WHERE v2productcategory IS NOT NULL AND productquantity > 0
GROUP BY v2productcategory, city, country
ORDER BY COUNT(v2productcategory) DESC;
```

Answer:  
There does not seem to be an obvious pattern besides more items are ordered from the United States, however there is a lot of missingness in the data which makes it difficult to assess validity. I ran two analyses: one based on productquantity, and one based on transactions. This is because I do not believe productquantity correlates with products sold (I think it may represent the number of products in the basket of a visitor at the time of data capture). I thought that transactions could provide a closer estimate of which product categories actually had a sale for their items. 

**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**


SQL Queries:
```SQL
WITH RankedProducts AS (
    SELECT 
        city, 
        country, 
        v2productname, 
        SUM(productquantity) AS total_sold,
        ROW_NUMBER() OVER (
            PARTITION BY city, country 
            ORDER BY SUM(productquantity) DESC
        ) AS rank
    FROM allsessions
    WHERE productquantity IS NOT NULL
    GROUP BY city, country, v2productname
)
SELECT city, country, v2productname, total_sold
FROM RankedProducts
WHERE rank = 1;
```

Answer:  
Note the same issue as above where it is unclear if productquantity represents sale (see QA for details).


**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:
```SQL

SELECT 
	city, 
	country, 
	SUM(transactionrevenue/1000000) AS tot_transactionrevenue,
	ROUND(((SUM(transactionrevenue/1000000) * 100) / 
	(SELECT SUM(transactionrevenue/1000000)
		FROM allsessions
	)), 1) AS percentage_totrev
FROM allsessions
GROUP BY city, country
HAVING SUM(transactionrevenue/1000000) > 0
ORDER BY SUM(transactionrevenue/1000000) DESC;


SELECT 
	city, 
	country, 
	SUM(totaltransactionrevenue/1000000) AS tot_transactionrevenue,
	ROUND(((SUM(totaltransactionrevenue/1000000) * 100) / 
	(SELECT SUM(totaltransactionrevenue/1000000)
		FROM allsessions
	)), 1) AS percentage_totrev
FROM allsessions
GROUP BY city, country
HAVING SUM(totaltransactionrevenue/1000000) > 0
ORDER BY SUM(totaltransactionrevenue/1000000) DESC;
```

Answer:  
While the data is still not reliable, in this analysis you can see what proportion of the revenue (for either transactionrevenue or totaltransactionrevenue) each country/city contributes to the overall revenue. 

