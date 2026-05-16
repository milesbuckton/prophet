IF OBJECT_ID(N'[Prophet].dbo.Orders', N'U') IS NULL
BEGIN
    CREATE TABLE [Prophet].dbo.Orders
    (
        OrderID INT NOT NULL PRIMARY KEY,
        CustomerID INT NOT NULL,
        OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
        TotalAmount DECIMAL(18,2) NULL
    );
END