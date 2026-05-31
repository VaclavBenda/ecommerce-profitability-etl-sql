/*
====================================================================
				DDL Script: Create Bronze Tables
====================================================================
Script Purpose:
 This script creates tables in the 'bronze' schema, dropping existing tables
 if they already exists.
 Run this script to re-define the DDL structure of 'bronze' tables.
 ====================================================================
*/

IF OBJECT_ID ('bronze.products', 'U') IS NOT NULL
	DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products (
	product_id NVARCHAR(50),
	product_name NVARCHAR(100),
	category NVARCHAR(50),
	sub_category NVARCHAR(50),
	unit_cost NVARCHAR(50),
	selling_price NVARCHAR(50),
	shipping_cost_per_unit NVARCHAR(50),
	weight_lbs NVARCHAR(50),
	supplier NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
	DROP TABLE bronze.orders;
GO

CREATE TABLE bronze.orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_date NVARCHAR(50),
	channel NVARCHAR(50),
	payment_method NVARCHAR(50),
	region NVARCHAR(50),
	items_ordered NVARCHAR(50),
	primary_category NVARCHAR(50),
	gross_revenue NVARCHAR(50),
	discount_pct NVARCHAR(50),
	discount_amount NVARCHAR(50),
	shipping_cost NVARCHAR(50),
	product_cost NVARCHAR(50),
	platform_fee NVARCHAR(50),
	transaction_fee NVARCHAR(50),
	returned NVARCHAR(50),
	refund_amount NVARCHAR(50),
	net_revenue NVARCHAR(50),
	total_costs NVARCHAR(50),
	profit NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.marketing_spend', 'U') IS NOT NULL
	DROP TABLE bronze.marketing_spend;
GO

CREATE TABLE bronze.marketing_spend (
	[month] NVARCHAR(50),
	[platform] NVARCHAR(50),
	spend NVARCHAR(50),
	impressions NVARCHAR(50),
	clicks NVARCHAR(50),
	conversions NVARCHAR(50),
	revenue_attributed NVARCHAR(50),
	cpc NVARCHAR(50),
	cpa NVARCHAR(50),
	roas NVARCHAR(50)
);
