----- ASSIGNMENT 3 -----

----- A) Create above table (Actions) and insert values,

CREATE TABLE Actions (
    [Visitor_ID] INT NOT NULL,
    [Adv_Type] VARCHAR(20) NOT NULL,
    [Action] VARCHAR (20) NOT NULL);


INSERT INTO Actions VALUES
(1,'A','Left'),
(2,'A','Order'),
(3,'B','Left'),
(4,'A','Order'),
(5,'A','Review'),
(6,'A','Left'),
(7,'B','Left'),
(8,'B','Order'),
(9,'B','Review'),
(10,'A','Review')

SELECT *
FROM Actions;

----- B) Retrieve count of total Actions and Orders for each Advertisement Type,

SELECT DISTINCT Adv_Type, COUNT([Action]) AS Num_of_adv_type
FROM Actions
GROUP BY Adv_Type;


----- C) Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.

--- FIRST WAY

SELECT distinct T1.Adv_Type as Adv_Type, CAST((Total_act * 1.0 / total) AS decimal (3,2) ) AS Conv_type
FROM (
	SELECT Adv_Type, COUNT(*) AS Total_act FROM Actions
	WHERE [Action] = 'Order'
	GROUP BY Adv_Type, [Action]
	) AS T1,
	(
	SELECT Adv_Type, COUNT(*) AS total FROM Actions
	GROUP BY adv_Type
	) AS T2
WHERE T1.Adv_Type = T2.Adv_Type


--- SECOND WAY

WITH T1 AS (
SELECT Adv_Type, COUNT([Action]) AS total FROM Actions
GROUP BY adv_Type
),
T2 AS (
SELECT Adv_Type, COUNT([Action]) AS Total_act FROM Actions
WHERE action = 'Order'
GROUP BY Adv_Type, Action
) 
SELECT distinct T1.Adv_Type as Adv_Type, CAST((Total_act * 1.0 / total) AS decimal (3,2) ) AS Conv_type
FROM T1, T2
WHERE T1.Adv_Type = T2.Adv_Type
;


--- THIRD WAY

	WITH T1 AS (
SELECT Adv_Type,count(*) AS total FROM Actions
GROUP BY adv_Type
),
T2 AS (
SELECT Adv_Type,count(*) AS Total_act FROM Actions
WHERE [Action] = 'Order'
GROUP BY Adv_Type, [Action]
) 
SELECT T1.Adv_Type AS Adv_Type, CONVERT(DECIMAL(10, 2),T2.Total_act * 1.0 / T1.total, 2) AS Conv_type 
FROM T1
JOIN T2 ON T1.Adv_Type = T2.Adv_Type
;



