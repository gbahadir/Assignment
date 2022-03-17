----- SQL ASSIGNMENT 4 -----	
WITH  
Table1 AS
	(
	SELECT	product_id, discount, SUM(quantity) SumOfQuantity,
			LEAD (SUM(quantity)) OVER(PARTITION BY product_id ORDER BY  discount) AS Lead1
	FROM	sale.order_item
	GROUP BY product_id, discount
	),
Table2	AS
	(
	SELECT product_id, SumOfQuantity, Lead1,
		CASE 
			WHEN Lead1 > SumOfQuantity THEN 1
			WHEN Lead1 < SumOfQuantity THEN -1
			WHEN Lead1 = SumOfQuantity THEN 0
			END AS Effect
	FROM Table1
	)
SELECT product_id, SUM(Effect) AS Sum_Effect,
		CASE 
			WHEN SUM(Effect) > 0 THEN 'Positive'
			WHEN SUM(Effect) < 0 THEN 'Negative'
			ELSE 'Neutral'
			END AS Disc_effect
FROM Table2
GROUP BY  product_id;

