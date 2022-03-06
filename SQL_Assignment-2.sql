-- SQL ASSIGNMENT 2 --

USE SampleRetail;

CREATE VIEW CUSTOMER_PRODUCT
AS
SELECT	distinct D.customer_id, D.first_name, D.last_name
FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE	A.product_id = B.product_id
AND		B.order_id = C.order_id
AND		C.customer_id = D.customer_id
AND		A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD';


SELECT * FROM [dbo].[CUSTOMER_PRODUCT];


CREATE VIEW FIRST_PRODUCT
AS
SELECT	distinct D.customer_id, A.product_name First_product
FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE	A.product_id = B.product_id
AND		B.order_id = C.order_id
AND		C.customer_id = D.customer_id
AND		A.product_name = 'Polk Audio - 50 W Woofer - Black';

SELECT * FROM [dbo].[FIRST_PRODUCT];

CREATE VIEW SECOND_PRODUCT
AS
SELECT	distinct D.customer_id, A.product_name Second_product
FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE	A.product_id = B.product_id
AND		B.order_id = C.order_id
AND		C.customer_id = D.customer_id
AND		A.product_name = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)';

SELECT * FROM [dbo].[SECOND_PRODUCT];

CREATE VIEW THIRD_PRODUCT
AS
SELECT	distinct D.customer_id, A.product_name Third_product
FROM	product.product A, sale.order_item B, sale.orders C, sale.customer D
WHERE	A.product_id = B.product_id
AND		B.order_id = C.order_id
AND		C.customer_id = D.customer_id
AND		A.product_name = 'Virtually Invisible 891 In-Wall Speakers (Pair)';

SELECT * FROM [dbo].[THIRD_PRODUCT];


CREATE VIEW CUSTOMER_FULL_PRODUCTS
AS
SELECT A.*, B.First_product, C.Second_product, D.Third_product
FROM [dbo].[CUSTOMER_PRODUCT] A
LEFT JOIN [dbo].[FIRST_PRODUCT] B
ON A.customer_id = B.customer_id
LEFT JOIN [dbo].[SECOND_PRODUCT] C
ON A.customer_id = C.customer_id
LEFT JOIN [dbo].[THIRD_PRODUCT] D
ON A.customer_id = D.customer_id

SELECT * FROM [dbo].[CUSTOMER_FULL_PRODUCTS];


SELECT 
    A.customer_id, 
    A.first_name, 
    A.last_name, 
    REPLACE(ISNULL(A.First_product, 'No'),'Polk Audio - 50 W Woofer - Black','Yes') First_product, 
    REPLACE(ISNULL(A.Second_product, 'No') , 'SB-2000 12 500W Subwoofer (Piano Gloss Black)','Yes')Second_product,
    REPLACE(ISNULL(A.Third_product, 'No'),'Virtually Invisible 891 In-Wall Speakers (Pair)', 'Yes') Third_product
FROM [dbo].[CUSTOMER_FULL_PRODUCTS] A
ORDER BY A.customer_id;



--------------------------------------------------------------------------------------
----- SECOND WAY ---------------------------------------------------------------------


SELECT 
	base.customer_id,
	base.first_name,
	base.last_name,
ISNULL(NULLIF(ISNULL(NULLIF(f1.product_name,'Yes'),'No'),'Polk Audio - 50 W Woofer - Black'),'Yes') AS First_product,
ISNULL(NULLIF(ISNULL(NULLIF(f2.product_name,'Yes'),'No'),'SB-2000 12 500W Subwoofer (Piano Gloss Black)'),'Yes') AS Second_product,
ISNULL(NULLIF(ISNULL(NULLIF(f3.product_name,'Yes'),'No'),'Virtually Invisible 891 In-Wall Speakers (Pair)'),'Yes') AS Third_product

FROM
(
SELECT 
	D.customer_id,
	D.first_name,
	D.last_name
FROM 
	sale.order_item B
JOIN product.product A ON A.product_id = B.product_id
JOIN sale.orders C ON C.order_id = B.order_id
JOIN sale.customer D ON D.customer_id = C.customer_id

WHERE A.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
) base 
LEFT JOIN 
(
SELECT 
	D.customer_id,
	D.first_name,
	D.last_name,
	A.product_name 
FROM 
	sale.order_item B

JOIN product.product A ON A.product_id = B.product_id
JOIN sale.orders C ON C.order_id = B.order_id
JOIN sale.customer D ON D.customer_id = C.customer_id

WHERE A.product_name = 'Polk Audio - 50 W Woofer - Black'
) f1
ON f1.customer_id = base.customer_id
LEFT JOIN 
(
SELECT 
	D.customer_id,
	D.first_name,
	D.last_name,
	A.product_name 
FROM sale.order_item B

JOIN product.product A ON A.product_id = B.product_id
JOIN sale.orders C ON C.order_id = B.order_id
JOIN sale.customer D ON D.customer_id = C.customer_id

WHERE A.product_name = 'SB-2000 12 500W Subwoofer (Piano Gloss Black)') f2
ON f2.customer_id = base.customer_id
LEFT JOIN 
(
SELECT 
	D.customer_id,
	D.first_name,
	D.last_name,
	A.product_name 
FROM sale.order_item B

JOIN product.product A ON A.product_id = B.product_id
JOIN sale.orders C ON B.order_id = C.order_id
JOIN sale.customer D ON D.customer_id = C.customer_id

WHERE A.product_name = 'Virtually Invisible 891 In-Wall Speakers (Pair)') f3
ON f3.customer_id = base.customer_id
ORDER BY base.customer_id;