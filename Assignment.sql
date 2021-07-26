/*
1.	List of Persons’ full name, all their fax and phone numbers, 
as well as the phone number and fax of the company they are working for (if any). 
*/
select P.FullName as Employee_FullName, P.FaxNumber as Employee_FaxNumber, 
P.PhoneNumber as Employee_PhoneNumber,
S.SupplierName as CompanyName, S.FaxNumber as Company_FaxNumber,
S.PhoneNumber as Company_PhoneNumber
from Purchasing.Suppliers S join Application.People P on S.PrimaryContactPersonID = P.PersonID
or S.AlternateContactPersonID = P.PersonID
--select employees info and company info for suppliers including both primary contact person and alternative
Union
select P.FullName as Employee_FullName, P.FaxNumber as Employee_FaxNumber, 
P.PhoneNumber as Employee_PhoneNumber,
C.CustomerName as CompanyName, C.FaxNumber as Company_FaxNumber,
C.PhoneNumber as Company_PhoneNumber
from Sales.Customers C join Application.People P on C.PrimaryContactPersonID = P.PersonID 
or C.AlternateContactPersonID = P.PersonID
where CustomerCategoryID != 1;
--select employees info and company info from customers including both primary contact person and alternative 
--combine select no1 and select no2 to get all the company info and employee info

/*
2.	If the customer's primary contact person has the same phone number as the customer’s phone number, 
list the customer companies. 
*/
select C.CustomerName as CompanyName from Sales.Customers C join Application.People P on C.PrimaryContactPersonID = P.PersonID
where C.CustomerCategoryID != 1 and C.PhoneNumber = P.PhoneNumber;

/*
3.	List of customers to whom we made a sale prior to 2016 but no sale since 2016-01-01.
*/
select distinct(C.CustomerName) from Sales.Customers C join Sales.CustomerTransactions T on C.CustomerID = T.CustomerID
group by C.CustomerName
having max(T.TransactionDate) < '2016-01-01'

/*
4.	List of Stock Items and total quantity for each stock item in Purchase Orders in Year 2013.
*/
select StockItemName, sum(S.QuantityPerOuter*OL.Quantity) from Sales.InvoiceLines IL join Sales.Invoices I on IL.InvoiceID = I.InvoiceID
join Sales.OrderLines OL on I.OrderID = OL.OrderID join Warehouse.StockItems S on OL.StockItemID = S.StockItemID
where year(I.InvoiceDate) = 2013
group by StockItemName;

/*
5.	List of stock items that have at least 10 characters in description.
*/
select StockItemName from Warehouse.Colors C join Warehouse.StockItems S on S.ColorID = C.ColorID 
where len(ColorName) + len(Size)>= 10; 

/*
6.	List of stock items that are not sold to the state of Alabama and Georgia in 2014.
*/
select distinct(StockItemName) from Sales.Customers C join Application.Cities CT on c.DeliveryCityID = CT.CityID
join Application.StateProvinces SP on CT.StateProvinceID = SP.StateProvinceID
join Sales.Invoices I on C.CustomerID = I.CustomerID
join Sales.InvoiceLines IL on IL.InvoiceID = I.InvoiceID
join Warehouse.StockItems SI on SI.StockItemID = IL.StockItemID
where SP.StateProvinceName != 'Alabama' and SP.StateProvinceName != 'Georgia' 
and year(I.InvoiceDate) = 2014;

/*
7.	List of States and Avg dates for processing (confirmed delivery date – order date).
*/
select SP.StateProvinceName, avg(DATEDIFF(day,O.OrderDate,I.ConfirmedDeliveryTime)) as AverageProcessingDays
from Application.StateProvinces SP 
join Application.Cities CT on SP.StateProvinceID = CT.StateProvinceID
join Sales.Customers C on CT.CityID = C.DeliveryCityID
join Sales.Invoices I on I.CustomerID = C.CustomerID
join Sales.Orders O on I.OrderID = O.OrderID
group by SP.StateProvinceName;

/*
8.	List of States and Avg dates for processing (confirmed delivery date – order date) by month.
*/
select SP.StateProvinceName, avg(DATEDIFF(day,O.OrderDate,I.ConfirmedDeliveryTime)) as AverageProcessingDays, 
month(O.OrderDate) as Month
from Application.StateProvinces SP 
join Application.Cities CT on SP.StateProvinceID = CT.StateProvinceID
join Sales.Customers C on CT.CityID = C.DeliveryCityID
join Sales.Invoices I on I.CustomerID = C.CustomerID
join Sales.Orders O on I.OrderID = O.OrderID
group by SP.StateProvinceName,MONTH(O.OrderDate)
order by SP.StateProvinceName,MONTH(O.OrderDate)
;

/*
9.	List of StockItems that the company purchased more than sold in the year of 2015.
*/
select StockItemName from Warehouse.StockItemTransactions SIT
join Warehouse.StockItems ST on SIT.StockItemID = ST.StockItemID
where year(TransactionOccurredWhen) = 2015
group by StockItemName
having sum(Quantity) > 0

/*
10.	List of Customers and their phone number, together with the primary contact person’s name, 
to whom we did not sell more than 10  mugs (search by name) in the year 2016
*/
select C.CustomerName, C.PhoneNumber, P.FullName
from sales.Customers C 
join sales.InvoiceLines IL on C.CustomerID = IL.StockItemID
join sales.Invoices I on IL.InvoiceID = I.InvoiceID
join Warehouse.StockItems SI on SI.StockItemID = IL.StockItemID
join Application.People P on C.PrimaryContactPersonID = P.PersonID
where year(I.InvoiceDate) =2016
group by C.CustomerName, C.PhoneNumber, P.FullName
having COUNT(case when SI.StockItemName like '%mug%' THEN 1 END) < 10

/*
11.	List all the cities that were updated after 2015-01-01.
*/
select * from Application.Cities
where year(ValidFrom) > 2015

/*
12.	List all the Order Detail (Stock Item name, delivery address, delivery state, city, country, 
customer name, customer contact person name, customer phone, quantity) 
for the date of 2014-07-01. Info should be relevant to that date.
*/
select C.CustomerName, C.PhoneNumber as CustomerPhoneNumber,
P.FullName as ContactName, P.PhoneNumber ContactPhoneNumber,
SI.StockItemName, IL.Quantity, C.DeliveryAddressLine1,
C.DeliveryAddressLine2,CT.CityName,
SP.StateProvinceName, Countries.CountryName, ConfirmedDeliveryTime
from Application.People P
join sales.Customers C on P.PersonID = C.PrimaryContactPersonID 
or P.PersonID = C.AlternateContactPersonID
join Sales.Invoices I on C.CustomerID = I.CustomerID
join Sales.InvoiceLines IL on IL.InvoiceID = I.InvoiceID
join Warehouse.StockItems SI on IL.StockItemID = SI.StockItemID
join Application.Cities CT on CT.CityID = C.DeliveryCityID
join Application.StateProvinces SP on SP.StateProvinceID = CT.StateProvinceID
join Application.Countries Countries on SP.CountryID = Countries.CountryID
where cast(I.ConfirmedDeliveryTime as date) = '2014-07-01'

/*13.	List of stock item groups and total quantity purchased, total quantity sold, 
and the remaining stock quantity (quantity purchased – quantity sold)*/
select * from Warehouse.StockItemStockGroups SISG join Warehouse.StockGroups SG
on SISG.StockGroupID = SG.StockGroupID
join(
select POL.StockItemID, sum(ReceivedOuters) TotalOuters from Purchasing.PurchaseOrderLines POL
group by POL.StockItemID) a
on a.StockItemID = SISG.StockItemID
join Warehouse.StockItems SI on a.StockItemID = SI.StockItemID
join sales.OrderLines OL on OL.StockItemID = a.StockItemID 
join Sales. Orders O on o.OrderID = OL.orderid


/*
14.	List of Cities in the US and the stock item that the city got the most deliveries in 2016. 
If the city did not purchase any stock items in 2016, print “No Sales”.
*/
select CT.CityID, count(SI.StockItemName) from Sales.Orders O join Sales.OrderLines OL 
on O.orderid = OL.OrderID
join Warehouse.StockItems SI on SI.StockItemID = OL.StockItemID
join Sales.Customers C on C.CustomerID = O.CustomerID
right join Application.Cities CT on C.DeliveryCityID = CT.CityID
join Application.StateProvinces SP
on CT.StateProvinceID = SP.StateProvinceID
where CT.CityID in (
select CityID from Application.Cities CT join Application.StateProvinces SP
on CT.StateProvinceID = SP.StateProvinceID
join Application.Countries Country
on SP.CountryID = Country.CountryID
where Country.CountryName = 'United States'
)
and year(O.orderdate) = 2016
group by CT.CityID
--order by si.StockItemName desc

/*
15.	List any orders that had more than one delivery attempt (located in invoice table).
*/

select O.OrderID,max(I.ConfirmedDeliveryTime) from 
sales.Invoices I join Sales.Orders O on O.OrderID = I.OrderID
where 
JSON_value(I.ReturnedDeliveryData, '$.Events[1].Comment') is not null
group by O.OrderID 

/*
16.	List all stock items that are manufactured in China. (Country of Manufacture)
*/
SELECT 
SI.StockItemName,
 JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture') as CountryOfManufacture
 from Warehouse.StockItems SI
 where JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture') = 'China' 

 /*
 17.	Total quantity of stock items sold in 2015, group by country of manufacturing.
 */
 /*
  select SI.StockItemName, count(OL.StockItemID) TotalOrder2015, 
 JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture') as CountryOfManufacture
 from Sales.OrderLines OL join Sales.Orders O on OL.OrderID = O.OrderID
 join Warehouse.StockItems SI on SI.StockItemID = OL.StockItemID
 where year(O.OrderDate) = 2015
 group by SI.StockItemName, JSON_VALUE(SI.CustomFields, '$.CountryOfManufacture')
 */



/*
 18.Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
 by year 2013-2017. [Stock Group Name, 2013, 2014, 2015, 2016, 2017]
 */
 
/*
create view StockGoupsTotalQuanlity as
select StockGroupName,[2013],[2014],[2015],[2016],[2017]
from
(
select sg.StockGroupName StockGroupName, year(o.OrderDate) years, sum(ol.Quantity) total_quantity
from 
Sales.OrderLines ol join sales.Orders o on ol.OrderID = o.OrderID
join Warehouse.StockItems i on ol.StockItemID = i.StockItemID
join Warehouse.StockItemStockGroups ssg on ssg.StockItemID = ol.StockItemID
join Warehouse.StockGroups sg on sg.StockGroupID = ssg.StockGroupID
where year(o.OrderDate) in ( 2013, 2014, 2015, 2016, 2017)
group by sg.StockGroupName, year(o.OrderDate)
) p
pivot
(
sum(p.total_quantity) 
for years in
([2013],[2014],[2015],[2016],[2017]) 
)as pivotTable
*/


/*
19.	Create a view that shows the total quantity of stock items of each stock group sold (in orders) 
by year 2013-2017. [Year, Stock Group Name1, Stock Group Name2, Stock Group Name3, � , Stock Group Name10] 
*/
/*
create view StockGoupsTotalQuanlityinYears as

select years, [Clothing], [USB Novelties], [Computing Novelties], 
[Novelty Items],[T-Shirts], [Mugs],[Furry Footwear],[Toys], [Packaging Materials]
from
(
select year(o.OrderDate) years, sg.StockGroupName StockGroupName, sum(ol.Quantity) total_quantity
from 
Sales.OrderLines ol join sales.Orders o on ol.OrderID = o.OrderID
join Warehouse.StockItems i on ol.StockItemID = i.StockItemID
join Warehouse.StockItemStockGroups ssg on ssg.StockItemID = ol.StockItemID
join Warehouse.StockGroups sg on sg.StockGroupID = ssg.StockGroupID
where year(o.OrderDate) in ( 2013, 2014, 2015, 2016, 2017)
group by sg.StockGroupName, year(o.OrderDate)
) p
pivot
(
sum(p.total_quantity)
for StockGroupName in ([Clothing], [USB Novelties], [Computing Novelties],
[Novelty Items],[T-Shirts], [Mugs],[Furry Footwear],[Toys], [Packaging Materials])
) as pivotTable
*/




 /*
 20.Create a function, input: order id; return: total of that order. 
 List invoices and use that function to attach the order total to the other fields of invoices. 
 */
/*
create function sales_totalorderprice(@orderid int) 
 returns int
 as
 begin
DECLARE @price int
select @price = sum(Quantity*UnitPrice)
 from
 Sales.Orders O join Sales.OrderLines OL on O.OrderID = OL.OrderID
 where O.OrderID = @orderid;
 return @price;
 end;


 create view InvoicesWithTotalOrderPrice
 as
 select *,dbo.sales_totalorderprice(Sales.Invoices.OrderID) TotalOrderPrice from sales.Invoices
 
 select * from InvoicesWithTotalOrderPrice
 */
 /*
 21.Create a new table called ods.Orders. Create a stored procedure, 
 with proper error handling and transactions, that input is a date; when executed, 
 it would find orders of that day, calculate order total, 
 and save the information (order id, order date, order total, customer id) into the new table. 
 If a given date is already existing in the new table, throw an error and roll back. 
 Execute the stored procedure 5 times using different dates. 
 */
 /*
 create schema ods

 create table ods.Orders(
 OrderID int not null,
 OrderDate datetime not null,
 OrderTotal int not null,
 CustomerId int not null
 );

 alter procedure Ods_Orders @Orderdate date
 as
 begin try
 begin transaction
 insert into ods.Orders
 select O.OrderID,O.OrderDate,dbo.sales_totalorderprice(o.OrderID) TotalOrderPrice,
 O.CustomerID
 from Sales.Orders O join Sales.OrderLines OL on O.OrderID = OL.OrderID
 where O.OrderDate = @Orderdate
 commit transaction
 end try 
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

exec Ods_Orders @orderdate ='2014-01-01'
exec Ods_Orders @orderdate ='2013-01-01'
*/


/*
 21.Create a new table called ods.Orders. Create a stored procedure, 
 with proper error handling and transactions, that input is a date; when executed, 
 it would find orders of that day, calculate order total, 
 and save the information (order id, order date, order total, customer id) into the new table. 
 If a given date is already existing in the new table, throw an error and roll back. 
 Execute the stored procedure 5 times using different dates. 
 */
 /*
 create schema ods

 create table ods.Orders(
 OrderID int not null,
 OrderDate datetime not null,
 OrderTotal int not null,
 CustomerId int not null
 );

 alter procedure Ods_Orders @Orderdate date
 as
 begin try
 begin transaction
 insert into ods.Orders
 select O.OrderID,O.OrderDate,dbo.sales_totalorderprice(o.OrderID) TotalOrderPrice,
 O.CustomerID
 from Sales.Orders O join Sales.OrderLines OL on O.OrderID = OL.OrderID
 where O.OrderDate = @Orderdate
 commit transaction
 end try 
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

exec Ods_Orders @orderdate ='2014-01-01'
exec Ods_Orders @orderdate ='2013-01-01'
*/


 /*
 22.Create a new table called ods.StockItem. 
 It has following columns: [StockItemID], [StockItemName] ,[SupplierID] ,[ColorID] ,[UnitPackageID] ,
 [OuterPackageID] ,[Brand] ,[Size] ,[LeadTimeDays] ,[QuantityPerOuter] ,[IsChillerStock] ,[Barcode] ,
 [TaxRate]  ,[UnitPrice],[RecommendedRetailPrice] ,[TypicalWeightPerUnit] ,[MarketingComments]  ,
 [InternalComments], [CountryOfManufacture], [Range], [Shelflife]. 
 Migrate all the data in the original stock item table.
 */
 /*
 create schema ods
 CREATE TABLE ods.StockItems(
	[StockItemID] [int] NOT NULL,
	[StockItemName] [nvarchar](100) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[ColorID] [int] NULL,
	[UnitPackageID] [int] NOT NULL,
	[OuterPackageID] [int] NOT NULL,
	[Brand] [nvarchar](50) NULL,
	[Size] [nvarchar](20) NULL,
	[LeadTimeDays] [int] NOT NULL,
	[QuantityPerOuter] [int] NOT NULL,
	[IsChillerStock] [bit] NOT NULL,
	[Barcode] [nvarchar](50) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[RecommendedRetailPrice] [decimal](18, 2) NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL,
	[MarketingComments] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[CountryOfManufacture] [nvarchar](50) NULL,
	[Range] [NVARCHAR](50) NULL,
	[Shelflife] [NVARCHAR](50) NULL
)
 
 
MERGE INTO ods.StockItems AS T
USING Warehouse.StockItems AS R
ON T.StockItemID = R.StockItemID
WHEN NOT MATCHED BY TARGET 
THEN INSERT VALUES 
(R.StockItemID, R.StockItemName, R.SupplierID, R.ColorID, 
R.UnitPackageID, R.OuterPackageID, R.Brand, R.Size, R.LeadTimeDays, 
R.QuantityPerOuter, R.IsChillerStock, R.Barcode, R.TaxRate, R.UnitPrice,
R.RecommendedRetailPrice, R.TypicalWeightPerUnit, R.MarketingComments,
R.InternalComments, JSON_VALUE(R.CustomFields, '$.CountryOfManufacture'),
JSON_VALUE(R.CustomFields, '$.Range'), JSON_VALUE(R.CustomFields, '$.ShelfLife'));





*/


/*
23.	Rewrite your stored procedure in (21). Now with a given date, 
it should wipe out all the order data prior to the input date and load the order data that was placed 
in the next 7 days following the input date.
*/
/*
 alter procedure Ods_Orders @Orderdate date
 as
 begin try
 begin transaction

 delete from ods.orders where 
 datediff(dd,orderdate,@Orderdate) > 0
 commit transaction
 end try
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH
 begin try
 begin transaction
 insert into ods.Orders
 select O.OrderID,O.OrderDate,dbo.sales_totalorderprice(o.OrderID) TotalOrderPrice,
 O.CustomerID
 from Sales.Orders O join Sales.OrderLines OL on O.OrderID = OL.OrderID
 where O.OrderDate = @Orderdate
 and DATEDIFF(dd,OrderDate,@Orderdate) <=7 
 and DATEDIFF(dd,OrderDate,@Orderdate) >=0
 commit transaction
 end try 
BEGIN CATCH
  SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
*/

/*
25.	Revisit your answer in (19). Convert the result in JSON string and save it 
to the server using TSQL FOR JSON PATH.
*/
/*
select * from [dbo].[StockGoupsTotalQuanlity]
for json auto
*/
/*26.	Revisit your answer in (19). Convert the result into an XML string and save it 
to the server using TSQL FOR XML PATH.
*/
/*
select * from [dbo].[StockGoupsTotalQuanlity]
for xml auto
*/
/*27.	Create a new table called ods.ConfirmedDeviveryJson with 3 columns (id, date, value) . 
Create a stored procedure, input is a date. 
The logic would load invoice information (all columns) as well as invoice line information (all columns) 
and forge them into a JSON string and then insert into the new table just created. 
Then write a query to run the stored procedure for each DATE that customer id 1 got something delivered to him.
*/

















