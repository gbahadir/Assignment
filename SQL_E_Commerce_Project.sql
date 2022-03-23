
----- E-COMMERCE PROJECT SOLUTION ----- 

-- 1) Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

SELECT * FROM cust_dimen;

SELECT * FROM market_fact;

SELECT * FROM orders_dimen;

SELECT * FROM prod_dimen;

SELECT * FROM shipping_dimen;


CREATE VIEW [combined_view] AS 
	(
    SELECT
		A.Ord_id, A.prod_id, A.Ship_id, A.Cust_id, A.Sales, A.Discount, A.Order_Quantity, A.Product_Base_Margin,
		B.Customer_Name, B.Province, B.Region, B.Customer_Segment,
		C.Order_Date, C.Order_Priority,
		D.Product_Category, D.Product_Sub_Category,
		E.Order_ID, E.Ship_Date, E.Ship_Mode
    FROM market_fact A 
    LEFT JOIN cust_dimen B ON A.Cust_id = B.Cust_id
    LEFT JOIN orders_dimen C ON A.Ord_id = C.Ord_id
    LEFT JOIN prod_dimen D ON A.Prod_id = D.Prod_id
    LEFT JOIN shipping_dimen E ON A.Ship_id = E.Ship_id
	);


SELECT * 
INTO combined_table
FROM [combined_view];




-- 2) Find the top 3 customers who have the maximum count of orders.

SELECT top 3 Cust_id, Customer_Name, COUNT(Order_Quantity) total_order
FROM combined_table
GROUP BY Cust_id, Customer_Name
ORDER BY total_order DESC;




-- 3) Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
-- Use "ALTER TABLE", "UPDATE" etc.

ALTER TABLE combined_table
ADD DaysTakenForDelivery INT
SELECT DATEDIFF(DAY, Order_Date, Ship_Date ) AS DaysTakenForDelivery
FROM combined_table


UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY, Order_Date, Ship_Date )
SELECT *
FROM combined_table




-- 4) Find the customer whose order took the maximum time to get delivered.
-- Use "MAX" or "TOP"

SELECT TOP 1 cust_id, customer_name order_date, Ship_Date, DaysTakenForDelivery
FROM combined_table
ORDER BY DaysTakenForDelivery DESC;


SELECT cust_id, customer_name order_date, Ship_Date, DaysTakenForDelivery
FROM combined_table
where DaysTakenForDelivery =
	(
	SELECT MAX(DaysTakenForDelivery)
	FROM combined_table
	);




-- 5) Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
-- You can use date functions and subqueries

SELECT	MONTH(Order_Date) Month_Num, 
		DATENAME(MONTH, Order_Date) Months, 
		COUNT(DISTINCT cust_id) Monthly_Num_of_Cust 
FROM combined_table
	WHERE cust_id IN 
	(
	SELECT DISTINCT cust_id FROM combined_table
	WHERE MONTH(Order_Date)=1 AND YEAR(Order_Date)=2011
	)
	AND YEAR(Order_Date) = 2011
group by MONTH(Order_Date), DATENAME(MONTH, Order_Date)
order by 1;

-- 2. Solution

SELECT	MONTH(Order_Date) Month_Num, 
		DATENAME(MONTH, Order_Date) Months,  
		COUNT(DISTINCT cust_id) Monthly_Num_of_Cust
FROM combined_table A     --exists te içerdeki query ile dışardakini bağlamam gerektiği için A dedim.
WHERE
EXISTS
	(
	SELECT cust_id
	FROM combined_table B
	WHERE YEAR(Order_Date) = 2011
	AND MONTH(Order_Date) = 1
	AND A.Cust_id = B.Cust_id
	)
AND YEAR(Order_Date) = 2011
GROUP BY MONTH(order_date), DATENAME(MONTH, Order_Date)
order by 1;




-- 6) Write a query to return for each user acording to the time elapsed between the first purchasing and the third purchasing, 
-- in ascending order by Customer ID
-- Use "MIN" with Window Functions


SELECT	DISTINCT Cust_id, first_order_date ,Order_Date AS third_order_date, 
		DATEDIFF(DAY, first_order_date, order_date) Date_difference
FROM 
	(
	SELECT
		DISTINCT Cust_id, Order_Date,	
		MIN(Order_date) over(Partition by Cust_id) first_order_date,
		DENSE_RANK() over(Partition by Cust_id order by order_date) third_order
	FROM combined_table
	) T
WHERE third_order = 3
;




-- 7) Write a query that returns customers who purchased both product 11 and product 14, 
-- as well as the ratio of these products to the total number of products purchased by all customers.
-- Use CASE Expression, CTE, CAST and/or Aggregate Functions

-- 1. Solution

SELECT cust_id,
	   SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 END) Prod_11_count,
	   SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 END) Prod_14_count,
	  (SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 END) + SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 END))* 1.0 / SUM (Order_Quantity)*100  AS Persentage
FROM combined_table
GROUP BY Cust_id
HAVING	SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 END) > 0
	AND SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 END) > 0;

-- 2. Solution

SELECT cust_id,
	   SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 END) Prod_11_count,
	   SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 END) Prod_14_count,
	  (SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 END) + SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 END))* 1.0 / SUM (Order_Quantity)*100  AS Persentage
FROM combined_table
WHERE Cust_id IN (
				SELECT Cust_id
				FROM combined_table
				WHERE Prod_id IN ('Prod_11', 'Prod_14')
				GROUP BY Cust_id
				HAVING COUNT(DISTINCT Prod_id)=2
				)
GROUP BY Cust_id;

-- 3. Solution

select cust_id,
	   SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 end) Prod_11_count,
	   SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 end) Prod_14_count,
	  (SUM(CASE WHEN Prod_id='Prod_11' THEN order_quantity ELSE 0 end) + SUM(CASE WHEN Prod_id='Prod_14' THEN order_quantity ELSE 0 end))* 1.0 / SUM (Order_Quantity)*100  AS Persentage
FROM combined_table
WHERE Cust_id IN (
				SELECT Cust_id
				FROM combined_table
				WHERE Prod_id = 'Prod_11'
				INTERSECT	 
				SELECT Cust_id
				FROM combined_table
				WHERE Prod_id = 'Prod_14'
				)
GROUP BY Cust_id;

-- 4. Solution

WITH T1 AS
		(
		SELECT	Cust_id,
				SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) P11,
				SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) P14,
				SUM (Order_Quantity) TOTAL_PROD
		FROM	combined_table
		GROUP BY Cust_id
		HAVING
				SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) >0 AND
				SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) >0
		)
SELECT	Cust_id, P11, P14, TOTAL_PROD,
		CAST (1.0*P11/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*P14/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P14,
		CAST (((1.0*P14 + 1.0*P11)/TOTAL_PROD) AS NUMERIC (3,2)) AS RATIO_P11plusP14
FROM T1;




----- CUSTOMER SEGMENTATION -----

-- 1) Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
-- Use such date functions. Don't forget to call up columns you might need later.

CREATE VIEW Cust_log AS

SELECT	Cust_id, 
		YEAR(Order_Date) Years, 
		MONTH(Order_Date) Months	
FROM combined_table
GROUP BY Cust_id, YEAR(Order_Date) , MONTH(Order_Date)
;


SELECT *
FROM Cust_log;




-- 2) Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
-- Don't forget to call up columns you might need later.

CREATE VIEW Monthly_Log AS

SELECT	Cust_id,
		Customer_Name,
		YEAR(Order_Date) Years, 
		DATENAME(MONTH,Order_Date) Months,
		COUNT(Order_Date) Monthly_visit
FROM combined_table
GROUP BY Cust_id, Customer_Name, YEAR(Order_Date) , DATENAME(MONTH,Order_Date)
;


SELECT *
FROM Monthly_Log;

-- Monthly visiting count

SELECT DATENAME(MONTH, order_date) Month_Visit, COUNT(*) Monthly_Visit_Count
FROM combined_table
GROUP BY DATENAME(MONTH, order_date)




-- 3) For each visit of customers, create the next month of the visit as a separate column.
-- You can order the months using "DENSE_RANK" function.
-- then create a new column for each month showing the next month using the order you have made above. (use "LEAD" function.)
-- Don't forget to call up columns you might need later.

CREATE VIEW Next_Visit AS

SELECT	*,
		LEAD(CURRENT_MONTH, 1) OVER (PARTITION BY Cust_id ORDER BY CURRENT_MONTH) Next_Visit_Month
FROM
	(SELECT *,
	DENSE_RANK() OVER(ORDER BY Years , Months) Current_Month
	FROM Monthly_Log
	) A

SELECT * 
FROM Next_Visit;


	
	
-- 4) Calculate monthly time gap between two consecutive visits by each customer.
-- Don't forget to call up columns you might need later.


CREATE VIEW Time_gaps AS

SELECT *,
		(Next_Visit_Month - Current_Month) Time_gaps

FROM	Next_Visit

select *
from Time_gaps



SELECT	Cust_id, 
		order_date, 
		second_order, 
		DATEDIFF(MONTH, order_date, second_order) Month_Gap
FROM 	
		(
		SELECT DISTINCT Cust_id, Order_Date,	
		MIN(Order_date) over(Partition by Cust_id) First_order_date,	 
		lead(Order_Date,1) over(partition by cust_id order by order_date) Second_order
		FROM combined_table
		) T
WHERE DATEDIFF(MONTH, order_date, second_order) > 0




-- 5) Categorise customers using average time gaps. Choose the most fitted labeling model for you.
-- For example: 
-- Labeled as “churn” if the customer hasn't made another purchase for the months since they made their first purchase.
-- Labeled as “regular” if the customer has made a purchase every month.
-- Etc.


SELECT	cust_id, avg_time_gap,
		CASE
			WHEN Avg_Time_Gap = 1 THEN 'Regular'
			WHEN Avg_Time_Gap > 1 THEN 'Irreguler'
			WHEN Avg_Time_Gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN DATA' 
			END CustLabels
FROM 
	(
	SELECT Cust_id, AVG(Time_gaps) Avg_Time_Gap
	FROM Time_gaps
	GROUP BY Cust_id
	) A
;



-- 2. Solution

WITH T1 AS
		(
		SELECT	Cust_id, 
				order_date, 
				second_order, 
				DATEDIFF(MONTH, order_date, second_order) Month_Gap
		FROM	(
				SELECT	DISTINCT Cust_id, Order_Date,	
						MIN(Order_date) OVER(PARTITION BY Cust_id) First_order_date,	
						LEAD(Order_Date, 1) OVER(PARTITION BY cust_id ORDER BY order_date) Second_order
				FROM combined_table
				) T
		)
SELECT	cust_id, 
		AVG(t1.Month_Gap) AS AvgTimeGap,
		CASE 
			WHEN AVG(T1.Month_Gap) <= 1 THEN 'Regular'
			WHEN AVG(T1.Month_Gap) IS NULL THEN 'Churn'			
			ELSE 'Irregular'	
			END CustLabels
FROM T1
GROUP BY Cust_id
;




----- MONTH-WISE RETENTION RATE -----

-- 1) Find month-by-month customer retention rate  since the start of the business.


SELECT DISTINCT YEAR(order_date) [year], 
                MONTH(order_date) [month],
                DATENAME(MONTH, order_date) [month_name],
                COUNT(cust_id) OVER (PARTITION BY YEAR(order_date), MONTH(order_date) order by YEAR(order_date), MONTH(order_date)) num_cust
FROM combined_table
;




-- 2) Calculate the month-wise retention rate.

-- Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month

-- It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
-- You can also use CTE or Subquery if you want.

-- You should pay attention to the join type and join columns between your views or tables.


CREATE VIEW Month_wise_retention_rate AS
	(
	SELECT DISTINCT YEAR(order_date) [year],
                MONTH(order_date) [month],
                DATENAME(MONTH,order_date) [month_name],
                COUNT(cust_id) OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY YEAR(order_date), MONTH(order_date)) num_cust
	FROM combined_table
	)
;



SELECT YEAR, MONTH, num_cust, LEAD(num_cust,1) OVER (ORDER BY YEAR, MONTH) rate_,
	FORMAT(num_cust * 1.0 * 100/(LEAD(num_cust,1) OVER (ORDER BY YEAR, MONTH, num_cust)),'N2')
FROM Month_wise_retention_rate
;


