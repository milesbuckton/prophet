SELECT CustomerID, COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID) > 10;

SELECT COUNT(*) AS TotalRows
FROM Orders
HAVING COUNT(*) > 1000;