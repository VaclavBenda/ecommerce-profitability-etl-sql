/*
==============================================================================
Quality Checks
==============================================================================
Script Purpose:
 This script perform various quality checks for data consistency, accuracy,
 and standardization across the 'silver' schema. It includes checks for:
 - Null or duplicate values.
 - Unwanted spaces in string fields.
 - Data standardization and consistency.
 - Invalid date ranges and orders.
 - Data consistency between related fields.

Usage Notes:
 - Run these checks after data loading Silver Layer.
 - Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/

-- ===========================================================
-- Checking 'silver.marketing_spend'
-- ===========================================================

-- Check for NULLs or Duplicates
-- Expectation: No Results
WITH duplicate_check_cte AS (
SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY month_start_date, [platform], spend, impressions, clicks, conversions, revenue_attributed, cpc, cpa, roas ORDER BY month_start_date) AS dups_check
FROM silver.marketing_spend
)
SELECT * FROM duplicate_check_cte
WHERE dups_check > 1;

SELECT [platform] FROM silver.marketing_spend
WHERE [platform] IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT [platform] FROM silver.marketing_spend
WHERE [platform] != TRIM([platform]);

-- Data Standardization & Consistency
SELECT DISTINCT([platform]) FROM silver.marketing_spend ORDER BY [platform];

-- Check for Invalid Dates
-- Expectation: No Results
SELECT * FROM silver.marketing_spend
WHERE month_start_date IS NULL 
	OR month_start_date > '2027-01-01';

-- Negative Values Check
-- Expectation: No Results
SELECT * FROM silver.marketing_spend
WHERE spend < 0 
	OR cpc < 0 
	OR cpa < 0 
	OR roas < 0;

-- Check if roas is matching (roas = revenue / spend)
-- Expectation: No Results

WITH verify_roas_cte AS (
	SELECT
		revenue_attributed,
		spend,
		roas,
		ROUND(revenue_attributed / NULLIF(spend,0), 2) AS verify_roas
	FROM silver.marketing_spend
)
SELECT * FROM verify_roas_cte
WHERE roas != verify_roas;

-- ===========================================================
-- Checking 'silver.orders'
-- ===========================================================

-- Check for NULLs or Duplicates
-- Expectation: No Results
SELECT 
	order_id, 
	COUNT(*) 
FROM silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id FROM silver.orders
WHERE order_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
	order_id, 
	customer_id, 
	channel, 
	payment_method, 
	region,
	primary_category
FROM silver.orders
WHERE order_id != TRIM(order_id)
	OR customer_id != TRIM(customer_id)
	OR channel != TRIM(channel)
	OR payment_method != TRIM(payment_method)
	OR region != TRIM(region)
	OR primary_category != TRIM(primary_category);

-- Data Standardization & Consistency
SELECT DISTINCT(channel) FROM silver.orders ORDER BY channel;

SELECT DISTINCT(payment_method) FROM silver.orders ORDER BY payment_method;

SELECT DISTINCT(region) FROM silver.orders ORDER BY region;

SELECT DISTINCT(primary_category) FROM silver.orders ORDER BY primary_category;

-- Check for Invalid Dates
-- Expectation: No Results
SELECT * FROM silver.orders
WHERE order_date IS NULL
	OR order_date > '2027-01-01';

-- Negative Values Check
-- Expectation: No Results
SELECT * FROM silver.orders
WHERE total_cost < 0
	OR shipping_cost < 0
	OR product_cost < 0
	OR discount_amount < 0
	OR platform_fee < 0
	OR transaction_fee < 0
	OR gross_revenue < 0;

-- Check if order-level costs add up correctly (product cost + shipping + fees = total costs)
-- Expectation: No Results
WITH total_cost_cte AS (
SELECT
	shipping_cost,
	product_cost,
	transaction_fee,
	total_cost,
	(shipping_cost + product_cost + transaction_fee + platform_fee) AS verify_total_cost

FROM silver.orders
)
SELECT * FROM total_cost_cte
WHERE total_cost != verify_total_cost;

-- Check if refund_amount is matching (gross_revenue - discount_amount)
-- Expectation: No Results
WITH refund_cte AS (
	SELECT
	gross_revenue,
	discount_amount,
	refund_amount,
	(gross_revenue - discount_amount) AS verify_refund
	FROM silver.orders
	WHERE returned = 'Yes'
)
SELECT * FROM refund_cte
WHERE refund_amount != verify_refund;

-- ===========================================================
-- Checking 'silver.products'
-- ===========================================================

-- Check for NULLs or Duplicates
-- Expectation: No Results
SELECT 
	product_id, 
	COUNT(*)
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT product_id FROM silver.products
WHERE product_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
	product_id,
	product_name,
	category,
	sub_category,
	supplier
FROM silver.products
WHERE product_id != TRIM(product_id)
	OR product_name != TRIM(product_name)
	OR category != TRIM(category)
	OR sub_category != TRIM(sub_category)
	OR supplier != TRIM(supplier);

-- Data Standardization & Consistency
SELECT DISTINCT(product_name) FROM silver.products ORDER BY product_name;

SELECT DISTINCT(category) FROM silver.products ORDER BY category;

SELECT DISTINCT(sub_category) FROM silver.products ORDER BY sub_category;

SELECT DISTINCT(supplier) FROM silver.products ORDER BY supplier;

-- Negative Values Check
-- Expectation: No Results
SELECT * FROM silver.products
WHERE unit_cost < 0
	OR selling_price < 0
	OR shipping_cost_per_unit < 0
	OR weight_lbs < 0;