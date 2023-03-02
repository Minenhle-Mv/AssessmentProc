USE [Northwind]
GO

/****** Object:  StoredProcedure [dbo].[pr_GetOrderSummary]    Script Date: 3/2/2023 1:25:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[pr_GetOrderSummary]
@StartDate date,
@EndDate date,
@EmployeeID int,
@CustomerID nvarchar(20)
As

if (@StartDate is null or @EndDate is null)
	Begin
	Raiserror('Please provide both start and end date',16,1)
	End
Else

Begin 

	Select CONCAT(e.TitleOfCourtesy,' ',e.FirstName,' ',e.LastName) as 'EmployeeFullName',
	s.CompanyName as ShipperCompanyName,
	c.CompanyName as CustomerCompanyName,
	orderdate, Sum(Freight) as TotalFreightCost,
	count(distinct od.OrderID) as NumberOfOrders,
	count(distinct p.ProductID) as NumberOfDifferentProducts,
	Sum (od.UnitPrice * od.Quantity) as TotalOrderValue 
	from Orders o
	JOIN Employees e ON e.EmployeeID = o.EmployeeID
	JOIN Customers c ON c.CustomerID = o.CustomerID
	JOIN  dbo.[Order Details] od ON od.OrderID = o.OrderID
	JOIN  Products p ON p.ProductID = od.ProductID
	JOIN Shippers s ON s.ShipperID = o.ShipVia
	where (o.EmployeeID = @EmployeeID OR @EmployeeID IS NULL) 
	and (c.CustomerID = @CustomerID OR @CustomerID IS NULL) 
	and orderdate between @StartDate and @EndDate
	group by orderdate,e.TitleOfCourtesy,e.FirstName,e.LastName, s.CompanyName, c.CompanyName 
End


GO

