--1. List of customers (name, city, id) and total quanitity of goods purchased on 2013/06/20 (check history)
 JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
 count(si.StockItemName)
 from Warehouse.StockItems SI
 group by JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture')