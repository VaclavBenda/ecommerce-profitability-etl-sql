/*
==========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================================================
Script Purpose:
 This stored procedure loads data into the 'bronze' schema from external CSV files.
 It performs the following actions:
 - Truncates the bronze tables before loading data
 - Uses the `BULK INSERT` command to load data from csv files to bronze tables.

Parameters:
 None.
 This stored procedure does not accept any parameters or return any values.

Usage Example:
 EXEC bronze.load_bronze;
==========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================';

		PRINT '----------------------------------------------';
		SET @start_time = GETDATE();
		PRINT 'Truncating Table: bronze.products';
		TRUNCATE TABLE bronze.products;
	
		PRINT '>> Inserting Data Into: bronze.products';
		BULK INSERT bronze.products
		FROM 'D:\E-Commerce project\products.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		PRINT '----------------------------------------------';
		SET @start_time = GETDATE();
		PRINT 'Truncating Table: bronze.orders';
		TRUNCATE TABLE bronze.orders;

		PRINT '>> Inserting Table: bronze.orders';
		BULK INSERT bronze.orders
		FROM 'D:\E-Commerce project\orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		PRINT '----------------------------------------------';
		SET @start_time = GETDATE()
		PRINT 'Truncating Table: bronze.marketing_spend';
		TRUNCATE TABLE bronze.marketing_spend;

		PRINT '>> Inserting Table: bronze.marketing_spend';
		BULK INSERT bronze.marketing_spend
		FROM 'D:\E-Commerce project\marketing_spend.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT 'Total Load Duration ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==============================================';
	END TRY
	BEGIN CATCH
		PRINT '==============================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT 'ERROR LINE' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT '==============================================';
	END CATCH
END;