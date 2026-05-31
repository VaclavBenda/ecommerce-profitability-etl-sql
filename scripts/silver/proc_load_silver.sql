/* 
==========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==========================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
  It performs the following actions:
  - Truncates Silver tables
  - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
==========================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '==============================================';
        PRINT 'Loading Silver Layer';
        PRINT '==============================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.products';
        TRUNCATE TABLE silver.products;
        PRINT '>> Inserting Table: silver.products';
        INSERT INTO silver.products (
            product_id,
	        product_name,
	        category,
	        sub_category,
	        unit_cost,
	        selling_price,
	        shipping_cost_per_unit,
	        weight_lbs,
	        supplier
        )
        SELECT 
			product_id,
			product_name,
			category,
			sub_category,
			CONVERT(NUMERIC(10,2), unit_cost) AS unit_cost,
			CONVERT(NUMERIC(10,2), selling_price) AS selling_price,
			CONVERT(NUMERIC(10,2), shipping_cost_per_unit) AS shipping_cost_per_unit,
			CONVERT(NUMERIC(10,1), weight_lbs) AS weight_lbs,
			supplier
		FROM bronze.products;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.orders';
        TRUNCATE TABLE silver.orders;
        PRINT '>> Inserting Table: silver.orders';
		INSERT INTO silver.orders (
			order_id,
			customer_id,
			order_date,
			channel,
			payment_method,
			region,
			items_ordered,
			primary_category,
			gross_revenue,
			discount_pct,
			discount_amount,
			shipping_cost,
			product_cost,
			platform_fee,
			transaction_fee,
			returned,
			refund_amount,
			net_revenue,
			total_cost,
			profit
		)
		SELECT 
			order_id,
			customer_id,
			CONVERT(DATE,order_date) AS order_date,
			channel,
			payment_method,
			CASE
				WHEN region = 'West Coast' THEN 'West'
				ELSE region
			END AS region,
			CONVERT(INT,items_ordered) AS items_ordered,
			primary_category,
			CONVERT(NUMERIC(10,2), gross_revenue) AS gross_revenue,
			CONVERT(INT, discount_pct) AS discount_pct,
			CONVERT(NUMERIC(10,2), discount_amount) AS discount_amount,
			CONVERT(NUMERIC(10,2), shipping_cost) AS shipping_cost,
			CONVERT(NUMERIC(10,2), product_cost) AS product_cost,
			CONVERT(NUMERIC(10,2), platform_fee) AS platform_fee,
			CONVERT(NUMERIC(10,2), transaction_fee) AS transaction_fee,
			returned,
			CONVERT(NUMERIC(10,2), refund_amount) AS refund_amount,
			CONVERT(NUMERIC(10,2), net_revenue) AS net_revenue,
			CONVERT(NUMERIC(10,2), total_costs) AS total_cost,
			CONVERT(NUMERIC(10,2), profit) AS profit
		FROM bronze.orders;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.marketing_spend';
        TRUNCATE TABLE silver.marketing_spend;
        PRINT '>> Inserting Table: silver.marketing_spend';
		INSERT INTO silver.marketing_spend (
			month_start_date,
			[platform],
			spend,
			impressions,
			clicks,
			conversions,
			revenue_attributed,
			cpc,
			cpa,
			roas
		)
		SELECT 
			CONVERT(DATE, [month] + '-01') AS month_start_date,
			[platform],
			CONVERT(NUMERIC(10,2), spend) AS spend,
			CONVERT(INT, impressions) AS impressions,
			CONVERT(INT, clicks) AS clicks,
			CONVERT(INT, conversions) AS conversions,
			CONVERT(NUMERIC(10,2), revenue_attributed) AS revenue_attributed,
			CONVERT(NUMERIC(10,2), cpc) AS cpc,
			CONVERT(NUMERIC(10,2), cpa) AS cpa,
			CONVERT(NUMERIC(10,2), roas) AS roas
		FROM bronze.marketing_spend;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '==============================================';
		PRINT 'Loading Silver Layer is Completed';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '==============================================';
    END TRY
	BEGIN CATCH
		PRINT '==============================================';
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT 'ERROR LINE' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT '==============================================';
	END CATCH
END;