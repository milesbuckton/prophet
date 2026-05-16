-- 0. Create the Prophet database (if it doesn't exist)
IF DB_ID(N'Prophet') IS NULL
BEGIN
    CREATE DATABASE [Prophet]
    ON PRIMARY (
        NAME = N'Prophet',
        FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\Prophet.mdf',
        SIZE = 64MB,
        FILEGROWTH = 64MB
    )
    LOG ON (
        NAME = N'Prophet_log',
        FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\Prophet_log.ldf',
        SIZE = 32MB,
        FILEGROWTH = 32MB
    );
END
GO

-- 1. Source table (if it doesn't exist)
IF OBJECT_ID(N'[Prophet].dbo.ActualLocalCosts', N'U') IS NULL
BEGIN
    CREATE TABLE [Prophet].dbo.ActualLocalCosts (
        [Sale ID]         NVARCHAR(50)     NOT NULL,
        [Barcode]         NVARCHAR(50)     NOT NULL,
        [Sequence Number] NVARCHAR(50)     NOT NULL,
        [Producer ID]     NVARCHAR(10)     NOT NULL,
        [Commodity Code]  NVARCHAR(50)     NULL,
        [Variety Code]    NVARCHAR(50)     NULL,
        [Pack Code]       NVARCHAR(50)     NULL,
        [Count Code]      NVARCHAR(50)     NULL,
        [Grade Code]      NVARCHAR(50)     NULL,
        [Cost Item]       NVARCHAR(50)     NULL,
        [Amount]          DECIMAL(18,2)    NULL,
        [VAT]             DECIMAL(18,2)    NULL,
        [Total]           DECIMAL(18,2)    NULL
    );
END
GO

-- 2. CostItems lookup table (if it doesn't exist)
IF OBJECT_ID(N'[Prophet].dbo.CostItems', N'U') IS NULL
BEGIN
    CREATE TABLE [Prophet].dbo.CostItems (
        [Code]         NVARCHAR(50)    NOT NULL PRIMARY KEY,
        [Group 1]      NVARCHAR(100)   NULL,
        [Report Order] INT             NULL
    );
END
GO

-- 3. View (if it doesn't exist)
IF OBJECT_ID(N'[Prophet].dbo.v_QXSys_Financial_ActualLocalCosts', N'V') IS NULL
BEGIN
    EXEC [Prophet].dbo.sp_executesql N'
    CREATE VIEW dbo.v_QXSys_Financial_ActualLocalCosts
    AS
    SELECT
        [Sale ID], [Barcode], [Sequence Number], [Producer ID],
        [Commodity Code], [Variety Code], [Pack Code],
        [Count Code], [Grade Code], [Cost Item],
        [Amount], [VAT], [Total]
    FROM dbo.ActualLocalCosts;';
END
GO