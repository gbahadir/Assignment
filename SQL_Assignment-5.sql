
----- SQL ASSIGNMENT 5 -----

-- Create a scalar-valued function that returns the factorial of a number you gave it.

CREATE FUNCTION udf_Mult_factoriyel
(@input INT)

RETURNS INT
AS BEGIN
DECLARE 
	@counter INT = 1,
	@sonuc INT = 1

-- SET @counter = 1
-- SET @sonuc = 1

WHILE @counter <= @input  
	BEGIN
		SET @sonuc = @sonuc * @counter
		SET @counter  += 1
	END;

RETURN @sonuc; 
END
;



SELECT dbo.udf_Mult_factoriyel(5);