-- Latest order per customer
SELECT o.CustomerID, o.OrderID, o.OrderDate, o.TotalAmount
FROM Orders o
    INNER JOIN (
SELECT CustomerID, MAX(OrderDate) AS LatestDate
    FROM Orders
    GROUP BY CustomerID
) latest ON o.CustomerID = latest.CustomerID
        AND o.OrderDate = latest.LatestDate;

-- Top 3 orders per customer
SELECT CustomerID, OrderID, OrderDate, TotalAmount
FROM (
   SELECT *,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS rn
    FROM Orders
 ) ranked
WHERE rn <= 3;