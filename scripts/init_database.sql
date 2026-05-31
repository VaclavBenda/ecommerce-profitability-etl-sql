/*
Create Database and Schemas

Script Purpose:
 This script creates a new database named 'Ecommerce_profitability' after checking if it already exists.
 If the database exists, it is dropped and recreated. 
 Additionally, the script sets up three schemas within the database: 'bronze', 'silver' and 'gold'.

CREATE DATABASE Ecommerce_profitability;
*/

USE master;
GO

/*
===================================================================
	  DROP AND RECREATE THE 'Ecommerce_profitability' DATABASE
===================================================================
*/

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Ecommerce_profitability')
BEGIN
	ALTER DATABASE Ecommerce_profitability SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Ecommerce_profitability;
END;
GO

/*
===================================================================
		  CREATE THE 'Ecommerce_profitability' DATABASE
===================================================================
*/

CREATE DATABASE Ecommerce_profitability;
GO

USE Ecommerce_profitability;
GO


/*
===================================================================
				 		CREATE SCHEMAS
===================================================================
*/

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;