/**************************************************************************************************************
NAME:    EC_IT143_W3.4_tr.sql
PURPOSE: Answer eight business and metadata questions using the AdventureWorks2022 sample database.

MODIFICATION LOG:
Ver      Date        Author             Description
-----    ----------  -----------------  -----------------------------------------------------------------------
1.0      11/10/2026  Tyler Robinson     Created this script for EC IT143 W3.4. Added eight documented SQL
                                        queries using AdventureWorks2022.

RUNTIME:
Not yet measured. Record the total execution time after running the complete script in SSMS.

NOTES:
This script demonstrates how to translate business questions into SQL statements. It uses SELECT statements,
filtering, INNER JOINs, aggregate functions, GROUP BY, ORDER BY, date filtering, and INFORMATION_SCHEMA views.
Each question includes its original author and an explanation of the SQL approach. All queries are read-only.
**************************************************************************************************************/

USE [AdventureWorks2022];
GO

/*
CATEGORY 1: BUSINESS USER - MARGINAL COMPLEXITY

-- Q1: Which products have a list price greater than $1,000?
-- Author: Gilton Bitirosi
-- A1: This query retrieves products with a list price greater than $1,000.
-- It displays the product ID, name, and list price, ordered from highest to lowest price.
*/

SELECT
    ProductID,
    Name,
    ListPrice
FROM Production.Product
WHERE ListPrice > 1000
ORDER BY ListPrice DESC;
GO

/*
-- Q2: Which products are marked as finished goods?
-- Author: Younger Gboe
-- A2: This query filters the Product table for products where FinishedGoodsFlag equals 1.
-- It displays the product ID, name, product number, and finished goods status.
*/

SELECT
    ProductID,
    Name,
    ProductNumber,
    FinishedGoodsFlag
FROM Production.Product
WHERE FinishedGoodsFlag = 1;
GO

/*
CATEGORY 2: BUSINESS USER - MODERATE COMPLEXITY

-- Q3: Which products belong to each product subcategory, and what is their list price?
-- Author: Gilton Bitirosi
-- A3: This query joins Product and ProductSubcategory using ProductSubcategoryID.
-- It displays each product alongside its subcategory and list price.
*/

SELECT
    ps.Name AS SubcategoryName,
    p.ProductID,
    p.Name AS ProductName,
    p.ListPrice
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS ps
    ON p.ProductSubcategoryID = ps.ProductSubcategoryID
ORDER BY
    ps.Name,
    p.Name;
GO

/*
-- Q4: Which customers are associated with a store, and what is the store name?
-- Author: Younger Gboe
-- A4: This query joins Customer and Store using the Customer StoreID
-- and Store BusinessEntityID columns to identify customers associated with stores.
*/

SELECT
    c.CustomerID,
    s.BusinessEntityID AS StoreID,
    s.Name AS StoreName
FROM Sales.Customer AS c
INNER JOIN Sales.Store AS s
    ON c.StoreID = s.BusinessEntityID
ORDER BY
    s.Name,
    c.CustomerID;
GO

/*
CATEGORY 3: BUSINESS USER - INCREASED COMPLEXITY

-- Q5: Which sales territories had the highest total revenue during 2012?
-- Author: Gilton Bitirosi
-- A5: This query joins SalesOrderHeader and SalesTerritory, filters orders to 2012,
-- and groups the results by territory. It counts orders and totals SubTotal,
-- which represents sales before tax and freight.
*/

SELECT
    st.Name AS TerritoryName,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount,
    SUM(soh.SubTotal) AS TotalRevenue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesTerritory AS st
    ON soh.TerritoryID = st.TerritoryID
WHERE soh.OrderDate >= '2012-01-01'
  AND soh.OrderDate < '2013-01-01'
GROUP BY st.Name
ORDER BY TotalRevenue DESC;
GO

/*
-- Q6: Which sales representatives handled orders during 2013, and what were their order
-- counts and total order values?
-- Author: Younger Gboe
-- A6: This query joins SalesOrderHeader, SalesPerson, and Person.
-- It filters orders to 2013, counts orders, and sums TotalDue,
-- which includes subtotal, tax, and freight.
*/

SELECT
    p.BusinessEntityID AS SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS SalesPersonName,
    COUNT(DISTINCT soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalOrderValue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesPerson AS sp
    ON soh.SalesPersonID = sp.BusinessEntityID
INNER JOIN Person.Person AS p
    ON sp.BusinessEntityID = p.BusinessEntityID
WHERE soh.OrderDate >= '2013-01-01'
  AND soh.OrderDate < '2014-01-01'
GROUP BY
    p.BusinessEntityID,
    p.FirstName,
    p.LastName
ORDER BY TotalOrderValue DESC;
GO

/*
CATEGORY 4: METADATA - INFORMATION_SCHEMA VIEWS

-- Q7: Which tables contain a ProductID column, and what are the column's data type
-- and nullability?
-- Author: Gilton Bitirosi
-- A7: This query uses INFORMATION_SCHEMA.COLUMNS and INFORMATION_SCHEMA.TABLES
-- to find base tables containing ProductID and display its data type and nullability.
*/

SELECT
    c.TABLE_SCHEMA,
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS AS c
INNER JOIN INFORMATION_SCHEMA.TABLES AS t
    ON c.TABLE_CATALOG = t.TABLE_CATALOG
    AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
    AND c.TABLE_NAME = t.TABLE_NAME
WHERE c.COLUMN_NAME = 'ProductID'
  AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY
    c.TABLE_SCHEMA,
    c.TABLE_NAME;
GO

/*
-- Q8: Which stored procedures are available in the AdventureWorks database,
-- and what are their schema and procedure names?
-- Author: Younger Gboe
-- A8: This query uses INFORMATION_SCHEMA.ROUTINES to retrieve stored procedures.
-- It filters out functions by selecting only routines with PROCEDURE as their type.
*/

SELECT
    ROUTINE_SCHEMA,
    ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY
    ROUTINE_SCHEMA,
    ROUTINE_NAME;
GO