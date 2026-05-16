SELECT MAX(QuantityKg) AS SecondLargestQuantity
FROM FruitShipments
WHERE QuantityKg < (SELECT MAX(QuantityKg) FROM FruitShipments);