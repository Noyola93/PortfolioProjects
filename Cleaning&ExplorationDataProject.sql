-- Looking at the database.
SELECT *
FROM PortfolioProject.dbo.NewUsedCarsDataset;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS;

-- Renaming columns.
EXEC sp_rename 'dbo.NewUsedCarsDataset.[price drop]', 'PriceDrop', 'COLUMN';
EXEC sp_rename 'dbo.NewUsedCarsDataset.UsedAndCertified', 'UsedOrCertified', 'COLUMN';

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLEANING THE DATA.

-- Extracting the price drop.
SELECT PriceDrop, 
	   SUBSTRING(PriceDrop, 2 , CHARINDEX(' ', PriceDrop) - 1)
FROM PortfolioProject.dbo.NewUsedCarsDataset;

-- Updating the PriceDrop column with the clean prices.
UPDATE PortfolioProject.dbo.NewUsedCarsDataset
SET PriceDrop = SUBSTRING(PriceDrop, 2 , CHARINDEX(' ', PriceDrop) - 1);

-- Spliting the car names from the release year.
SElECT [Car Names], 
	   SUBSTRING([Car Names], 1 , CHARINDEX(' ',[Car Names])-1) AS Year,
	   SUBSTRING([Car Names], CHARINDEX(' ',[Car Names]), LEN([Car Names])) AS CarNames
FROM PortfolioProject..NewUsedCarsDataset;

-- Adding Year column to the table.
ALTER TABLE PortfolioProject..NewUsedCarsDataset
ADD Year INT;

-- Updating Year column with the release year estracted from Car Names
UPDATE  [PortfolioProject].[dbo].NewUsedCarsDataset
SET Year = CAST(SUBSTRING([Car Names], 1 , CHARINDEX(' ',[Car Names])-1) AS int);

-- Adding a new Cars Name column.
ALTER TABLE PortfolioProject.dbo.NewUsedCarsDataset
ADD CarNames VARCHAR(225);

UPDATE PortfolioProject.dbo.NewUsedCarsDataset
SET CarNames = SUBSTRING([Car Names], CHARINDEX(' ', [Car Names]), LEN([Car Names]));

-- Cleaning the UsedOrCertified column
SELECT SUBSTRING(UsedOrCertified, CHARINDEX(' C', UsedOrCertified) + 1 , LEN(UsedOrCertified))
FROM PortfolioProject..NewUsedCarsDataset;

UPDATE PortfolioProject.dbo.NewUsedCarsDataset
SET UsedOrCertified = SUBSTRING(UsedOrCertified, CHARINDEX(' C', UsedOrCertified) + 1 , LEN(UsedOrCertified));

-- Calculating the cars prices before the price drop.
SELECT Price, PriceDrop, Price + PriceDrop AS PriceBeforeDrop
FROM PortfolioProject.dbo.NewUsedCarsDataset

-- Adding a column with the price before the price drop.
ALTER TABLE PortfolioProject.dbo.NewUsedCarsDataset
ADD PriceBeforeDrop MONEY;

-- Updating the new column with the price before the drop.
UPDATE  PortfolioProject.dbo.NewUsedCarsDataset
SET PriceBeforeDrop = (Price + PriceDrop);

-- Indentifying duplicates using a Window Fuction
SELECT *,
	   ROW_NUMBER() OVER(
	   PARTITION BY YEAR, 
					CarNames, 
					Ratings, 
					Reviews, 
					Price, 
					PriceDrop 
					ORDER BY PRICE, 
					PriceDrop) AS row_num
FROM PortfolioProject.dbo.NewUsedCarsDataset;

-- Deleting Duplicates using a Common Table Expression (CTE).
WITH Duplicate AS (
SELECT *,
	   ROW_NUMBER() OVER(
	   PARTITION BY YEAR, 
					CarNames, 
					Ratings, 
					Reviews, 
					Price, 
					PriceDrop 
					ORDER BY PRICE, 
					PriceDrop) row_num
FROM PortfolioProject.dbo.NewUsedCarsDataset)
-- SELECT * before DELETE to validate that we will delete only the duplicates
DELETE
FROM Duplicate
WHERE row_num > 1;

-- Deleting useless columns.
ALTER TABLE PortfolioProject.dbo.NewUsedCarsDataset
DROP COLUMN Ratings, Reviews, [Car Names], Mileages;

-- Changing PriceDrop datatype to do calculation.
ALTER TABLE PortfolioProject.dbo.NewUsedCarsDataset
ALTER COLUMN PriceDrop MONEY; 

------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS.

-- Number of cars
SELECT COUNT(*)
FROM PortfolioProject.dbo.NewUsedCarsDataset;

-- Number of used cars
SELECT COUNT(UsedOrCertified)
FROM PortfolioProject.dbo.NewUsedCarsDataset
WHERE UsedOrCertified LIKE 'Used';

-- Number of new cars
SELECT COUNT(UsedOrCertified)
FROM PortfolioProject.dbo.NewUsedCarsDataset
WHERE UsedOrCertified LIKE 'Certified';

-- The total number of new cars by each car's model (Pivot Table).
SELECT UsedOrCertified,
       CarNames,
	   COUNT(*) AS TotalNewCars
FROM PortfolioProject.dbo.NewUsedCarsDataset
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Certified'
ORDER BY TotalNewCars DESC;

-- The total number of used cars by each car's model (Pivot Table).
SELECT UsedOrCertified,
       CarNames,
	   COUNT(*) AS TotalUsedCars
FROM PortfolioProject.dbo.NewUsedCarsDataset
GROUP BY CUBE(UsedOrCertified, CarNames)
HAVING UsedOrCertified LIKE 'Used'
ORDER BY TotalUsedCars DESC;

-- Drop price percent
SELECT Year, 
	   CarNames,
	   PriceDrop,
	   PriceBeforeDrop,
	   (PriceDrop/PriceBeforeDrop) * 100 AS PriceDropPercent
FROM [PortfolioProject].[dbo].NewUsedCarsDataset
ORDER BY PriceDropPercent DESC;

-- The average price drop percent for used cars compare to the total average price drop . 
WITH DropPriceP(UsedOrCertified,
				CarNames,
				DropPricePercent) AS (
SELECT UsedOrCertified, 
	   CarNames,
	   (PriceDrop/PriceBeforeDrop) * 100 AS DropPriceP
FROM [PortfolioProject].[dbo].NewUsedCarsDataset)

SELECT UsedOrCertified, 
	   CarNames,
       AVG((PriceDrop/PriceBeforeDrop) * 100) AS UsedPriceDropP,
	   -- Subquery with the total average drop price.
	   (SELECT AVG(DropPricePercent)
		FROM DropPriceP) AS TotalPriceDropPercent
FROM [PortfolioProject].[dbo].NewUsedCarsDataset
-- Pivot table that shows the total average % price drop of the new cars at the end of the table.
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Used';

-- The average price drop percent for used cars compare to the total 
WITH DropPriceP(UsedOrCertified,
				CarNames,
				DropPricePercent) AS (
SELECT UsedOrCertified, 
	   CarNames,
	   (PriceDrop/PriceBeforeDrop) * 100 AS DropPricePercent
FROM [PortfolioProject].[dbo].NewUsedCarsDataset)

SELECT UsedOrCertified, 
	   CarNames,
       AVG((PriceDrop/PriceBeforeDrop) * 100) AS NewCarsPriceDropP,
	   -- Subquery with the total average drop price.
	   (SELECT AVG(DropPricePercent)
		FROM DropPriceP) AS TotalPriceDropP
FROM [PortfolioProject].[dbo].NewUsedCarsDataset
-- Pivot table that shows the total average % price drop of the new cars at the end of the table.
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Certified';
--------------------------------------------------------------------------------------------------------------------------------------------

--- CREATING VIEWS FOR A FUTURE VISUALIZATION PROJECT

-- View # 1
CREATE VIEW  TotalNewCars AS
SELECT UsedOrCertified,
       CarNames,
	   COUNT(*) AS TotalNewCars
FROM PortfolioProject.dbo.NewUsedCarsDataset
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Certified';

-- View # 2
CREATE VIEW  TotalUsedCars AS
SELECT UsedOrCertified,
       CarNames,
	   COUNT(*) AS TotalUsedCars
FROM PortfolioProject.dbo.NewUsedCarsDataset
GROUP BY CUBE(UsedOrCertified, CarNames)
HAVING UsedOrCertified LIKE 'Used';

-- View # 3
CREATE VIEW  NewAvgPriceDropVsTotalAvg AS
WITH DropPriceP(UsedOrCertified,
				CarNames,
				DropPricePercent) AS (
SELECT UsedOrCertified, 
	   CarNames,
	   (PriceDrop/PriceBeforeDrop) * 100 AS DropPricePercent
FROM [PortfolioProject].[dbo].NewUsedCarsDataset)

SELECT UsedOrCertified, 
	   CarNames,
       AVG((PriceDrop/PriceBeforeDrop) * 100) AS NewCarsPriceDropP,
	   -- Subquery with the total average drop price.
	   (SELECT AVG(DropPricePercent)
		FROM DropPriceP) AS TotalPriceDropP
FROM [PortfolioProject].[dbo].NewUsedCarsDataset
-- Pivot table that shows the total average % price drop of the new cars at the end of the table.
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Certified';


-- View # 4
CREATE VIEW  UsedAvgPriceDropVsTotalAvg AS
WITH DropPriceP(UsedOrCertified,
				CarNames,
				DropPricePercent) AS (
SELECT UsedOrCertified, 
	   CarNames,
	   (PriceDrop/PriceBeforeDrop) * 100 AS DropPricePercent
FROM [PortfolioProject].[dbo].NewUsedCarsDataset)


SELECT UsedOrCertified, 
	   CarNames,
       AVG((PriceDrop/PriceBeforeDrop) * 100) AS NewCarsPriceDropP,
	   -- Subquery with the total average drop price.
	   (SELECT AVG(DropPricePercent)
		FROM DropPriceP) AS TotalPriceDropP
FROM [PortfolioProject].[dbo].NewUsedCarsDataset
-- Pivot table that shows the total average % price drop of the new cars at the end of the table.
GROUP BY CUBE(CarNames, UsedOrCertified) 
HAVING UsedOrCertified LIKE 'Certified';
