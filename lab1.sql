/* 
with T as(
select distinct SG.StockGroupName, SISG.StockItemID from 
Warehouse.StockGroups SG join Warehouse.StockItemStockGroups SISG on SG.StockGroupID = SISG.StockGroupID
)
select T2.CustomerName,T2.CityName from
(select C.CustomerName, CT.CityName, C.CustomerID from 
Sales.Customers C join Application.Cities CT on C.PostalCityID = CT.CityID
) T2
join
(select O.CustomerID, year(o.OrderDate) orderyear, ol.Quantity from 
Sales.OrderLines OL join Sales.Orders O on OL.OrderID = O.OrderID and year(OrderDate) = '2016'
join
t on t.StockItemID = OL.StockItemID where t.StockGroupName = 'toy') T3
on t3.CustomerID = t2.CustomerID
*/


select a.StockItemID,SI.StockItemName, a.TotalQuantity,a.import,a.sales from 
(select SIT.StockItemID, sum(Quantity) TotalQuantity, 
sum(case when Quantity > 0 then Quantity else 0 end) import,
sum(case when Quantity < 0 then Quantity else 0 end) sales
from Warehouse.StockItemTransactions SIT
where year(SIT.LastEditedWhen) = 2016
group by SIT.StockItemID) a
join
Warehouse.StockItems SI on SI.StockItemID = a.StockItemID
where a.TotalQuantity > 0




select b.TotalSalePrice from
(select OL.StockItemID, O.OrderDate, OL.Quantity*OL.UnitPrice TotalSalePrice
from
sales.OrderLines OL join Sales.Orders O on O.OrderID = OL.OrderID 
join 
(select StockItemName,SISG.StockItemID,SISG.StockGroupID from
Warehouse.StockItemStockGroups SISG join Warehouse.StockItems SI on SISG.StockItemID = SI.StockItemID
where SISG.StockGroupID in (select StockGroupID from Sales.SpecialDeals)
) a 
on OL.StockItemID = a.StockItemID
) b


