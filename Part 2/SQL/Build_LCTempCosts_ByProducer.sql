DECLARE @sLCCostTable NVARCHAR(100),
        @ServerID VARCHAR(10),
        @psProducerID NVARCHAR(10),
        @SQL NVARCHAR(MAX) = ''

SET @ServerID = CAST(@@SPID AS VARCHAR)
SET @sLCCostTable = 'LCTempCostsFor' + @ServerID
SET @psProducerID = 'ALICEDAUSD' --'Testproducer'

-- Drop the temp table if it already exists otherwise SELECT INTO fails
DECLARE @DropSQL NVARCHAR(200)
    = N'IF OBJECT_ID(N''' + @sLCCostTable + ''', N''U'') IS NOT NULL DROP TABLE ' + @sLCCostTable;

EXEC [Prophet].dbo.sp_executesql @DropSQL;

SET @SQL
    = 'SELECT [Sale ID], [Barcode], [Sequence Number], [Description],
    SUM([Amount]) AS Amount, SUM([VAT]) AS [VAT], SUM([Total]) AS Total
INTO ' + @sLCCostTable
      + '
FROM (SELECT V.[Sale ID],
        V.[Barcode],
        V.[Sequence Number],
        V.[Producer ID],
        V.[Commodity Code],
        V.[Variety Code],
        V.[Pack Code],
        V.[Count Code],
        V.[Grade Code],
        ''L-'' + COALESCE(CI.[Group 1],'''') AS [Description],
        SUM(ISNULL(V.[Amount],0)) AS Amount,
        SUM(ISNULL(V.[VAT],0)) AS [VAT],
        SUM(ISNULL(V.[Total],0)) AS Total,
        MIN(ISNULL(CI.[Report Order],0)) AS [Report Order]
    FROM v_QXSys_Financial_ActualLocalCosts V
        LEFT OUTER JOIN CostItems CI ON V.[Cost Item] = CI.[Code]
    WHERE V.[Producer ID] = ''' + @psProducerID
      + '''
    GROUP BY V.[Sale ID], V.[Barcode], V.[Sequence Number], V.[Producer ID],
V.[Commodity Code], V.[Variety Code], V.[Pack Code],
V.[Count Code], V.[Grade Code],
''L-'' + COALESCE(CI.[Group 1],'''')) AS SUB
GROUP BY [Sale ID], [Barcode], [Sequence Number], [Description]'

EXEC [Prophet].dbo.sp_executesql @SQL