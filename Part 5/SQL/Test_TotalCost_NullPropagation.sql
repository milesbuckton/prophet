DECLARE @BasePrice FLOAT = NULL, @VATAmount FLOAT = NULL;

SET @BasePrice = 10.90;

-- Returns NULL due to NULL propagation
SELECT (@BasePrice + @VATAmount) AS TotalCost;

-- T-SQL specific
SELECT (@BasePrice + ISNULL(@VATAmount, 0)) AS TotalCost;

-- ANSI SQL standard
SELECT (@BasePrice + COALESCE(@VATAmount, 0)) AS TotalCost;

-- Handle both variables being NULL
SELECT (COALESCE(@BasePrice, 0) + COALESCE(@VATAmount, 0)) AS TotalCost;