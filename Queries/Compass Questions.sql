Answer the following questions and provide the SQL queries used to find the answer.

    
**Question 1: Which cities and countries have the highest level of transaction revenues on the site?**


SQL Queries:

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


Answer:

**assumed revenue also needed to divide by 1000000
***transaction revenue v. totaltransaction revenue unclear
**not all products viewed were paid for and unable to assess totalordered if could connect with sales data



**Question 2: What is the average number of products ordered from visitors in each city and country?**


SQL Queries:

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

Answer:

**unsure if product/item quantity so ran both





**Question 3: Is there any pattern in the types (product categories) of products ordered from visitors in each city and country?**


SQL Queries:

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

Answer:





**Question 4: What is the top-selling product from each city/country? Can we find any pattern worthy of noting in the products sold?**
/*
SELECT DISTINCT city, country, v2productname, SUM(productquantity) AS total_sold
FROM allsessions
WHERE productquantity IS NOT NULL
GROUP BY city, country, v2productname
ORDER BY SUM(productquantity) DESC;
*/

SELECT 
	DISTINCT city, 
	country,
	RANK() OVER(ORDER BY SUM(productquantity) DESC) AS total_sold
FROM allsessions
WHERE productquantity IS NOT NULL
GROUP BY city, country;

SELECT DISTINCT city, country, v2productname, SUM(productquantity) AS total_sold
FROM allsessions
WHERE productquantity IS NOT NULL
GROUP BY city, country, v2productname
ORDER BY SUM(productquantity) DESC;

SQL Queries:



Answer:





**Question 5: Can we summarize the impact of revenue generated from each city/country?**

SQL Queries:

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


Answer:
