IF OBJECT_ID(N'[Prophet].dbo.FruitShipments', N'U') IS NULL
BEGIN
    CREATE TABLE [Prophet].dbo.FruitShipments
    (
        ShipmentID INT NOT NULL PRIMARY KEY,
        FruitType NVARCHAR(100) NOT NULL,
        QuantityKg DECIMAL(10,2) NULL
    );
END