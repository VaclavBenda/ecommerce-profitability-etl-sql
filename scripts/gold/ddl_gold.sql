/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
 This script creates analytical views in the 'gold' schema.
 These views aggregate and transform data from the 'silver' layer
 into business-ready datasets for reporting and analysis.

 Views Created:
 - gold.monthly_profitability: Monthly revenue, cost, profit, and return performance.
 - gold.category_profitability: Profitability metrics by product category.
 - gold.marketing_performance: Marketing spend, conversion, and ROAS performance.

 Usage:
 Use these views for dashboarding, reporting, and profitability analysis.
 ===============================================================================
*/

IF OBJECT_ID('gold.monthly_profitability', 'V') IS NOT NULL
	DROP VIEW gold.monthly_profitability;
GO

CREATE VIEW gold.monthly_profitability AS 
WITH monthly_profit_cte AS (
	SELECT 
		DATETRUNC(month, order_date) AS [month],
		COUNT(order_id) AS total_orders,
		SUM(gross_revenue) AS total_gross_revenue,
		SUM(net_revenue) AS total_net_revenue,
		SUM(total_cost) AS total_cost,
		SUM(profit) AS total_profit,
		SUM(refund_amount) AS total_refund_amount,
		COUNT(CASE WHEN returned = 'Yes' THEN order_id END) AS returned_orders
	FROM silver.orders
	GROUP BY DATETRUNC(month, order_date)
)
SELECT 
	[month],
	total_orders,
	total_gross_revenue,
	total_net_revenue,
	total_cost,
	total_profit,
	ROUND(CAST(total_profit AS FLOAT) / NULLIF(total_net_revenue, 0) * 100, 2) AS profit_margin_pct,
	returned_orders,
	total_refund_amount,
	ROUND(returned_orders / CAST(NULLIF(total_orders, 0) AS FLOAT) * 100, 2) AS return_rate_pct
FROM monthly_profit_cte;
GO

IF OBJECT_ID('gold.category_profitability', 'V') IS NOT NULL
	DROP VIEW gold.category_profitability;
GO

CREATE VIEW gold.category_profitability AS
WITH category_profit_cte AS (
	SELECT
		primary_category,
		COUNT(order_id) AS total_orders,
		SUM(items_ordered) AS total_items_ordered,
		SUM(gross_revenue) AS total_gross_revenue,
		SUM(net_revenue) AS total_net_revenue,
		SUM(total_cost) AS total_cost,
		SUM(profit) AS total_profit,
		COUNT(CASE WHEN returned = 'Yes' THEN order_id END) AS returned_orders
	FROM silver.orders
	GROUP BY primary_category
)
SELECT 	primary_category,
	total_orders,
	total_items_ordered,
	total_gross_revenue,
	total_net_revenue,
	total_cost,
	total_profit,
	ROUND(CAST(total_profit AS FLOAT) / NULLIF(total_orders, 0), 2) AS average_order_profit,
	ROUND(CAST(total_profit AS FLOAT) / NULLIF(total_net_revenue, 0) * 100, 2) AS profit_margin_pct,
	ROUND(CAST(returned_orders AS FLOAT) / NULLIF(total_orders, 0) * 100, 2) AS return_rate_pct
FROM category_profit_cte;
GO

IF OBJECT_ID('gold.marketing_performance', 'V') IS NOT NULL
	DROP VIEW gold.marketing_performance;
GO

CREATE VIEW gold.marketing_performance AS
WITH marketing_performance_cte AS (
	SELECT
		month_start_date,
		[platform],
		SUM(spend) AS total_spend,
		SUM(impressions) AS total_impressions,
		SUM(clicks) AS total_clicks,
		SUM(conversions) AS total_conversions,
		SUM(revenue_attributed) AS total_revenue_attributed
	FROM silver.marketing_spend
	GROUP BY month_start_date, [platform]
)
SELECT 	
	month_start_date,
	[platform],
	total_spend,
	total_impressions,
	total_clicks,
	total_conversions,
	total_revenue_attributed,
	ROUND(CAST(total_clicks AS FLOAT) / NULLIF(total_impressions, 0) * 100, 2) AS ctr_pct,
	ROUND(CAST(total_conversions AS FLOAT) / NULLIF(total_clicks, 0) * 100, 2) AS conversion_rate_pct,
	ROUND(CAST(total_spend AS FLOAT) / NULLIF(total_clicks, 0), 2) AS cpc,
	ROUND(CAST(total_spend AS FLOAT) / NULLIF(total_conversions, 0), 2) AS cpa,
	ROUND(CAST(total_revenue_attributed AS FLOAT) / NULLIF(total_spend, 0), 2) AS roas
FROM marketing_performance_cte;
