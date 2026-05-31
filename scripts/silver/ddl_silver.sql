/*
====================================================================
DDL Script: Create Silver Tables
====================================================================
Script Purpose:
 This script creates tables in the 'silver' schema, dropping existing tables
 if they already exist.
 Run this script to re-define the DDL structure of 'silver' Tables
====================================================================
*/

IF OBJECT_ID('silver.products', 'U') IS NOT NULL
	DROP TABLE silver.products;
GO

CREATE TABLE silver.products (
	product_id NVARCHAR(50),
	product_name NVARCHAR(100),
	category NVARCHAR(50),
	sub_category NVARCHAR(50),
	unit_cost DECIMAL(10,2),
	selling_price DECIMAL(10,2),
	shipping_cost_per_unit DECIMAL(10,2),
	weight_lbs DECIMAL(10,1),
	supplier NVARCHAR(50),
	create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.orders', 'U') IS NOT NULL
	DROP TABLE silver.orders
GO

CREATE TABLE silver.orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_date DATE,
	channel NVARCHAR(50),
	payment_method NVARCHAR(50),
	region NVARCHAR(50),
	items_ordered INT,
	primary_category NVARCHAR(50),
	gross_revenue NUMERIC(10,2),
	discount_pct INT,
	discount_amount NUMERIC(10,2),
	shipping_cost NUMERIC(10,2),
	product_cost NUMERIC(10,2),
	platform_fee NUMERIC(10,2),
	transaction_fee NUMERIC(10,2),
	returned NVARCHAR(50),
	refund_amount NUMERIC(10,2),
	net_revenue NUMERIC(10,2),
	total_cost NUMERIC(10,2),
	profit NUMERIC(10,2),
	create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.marketing_spend', 'U') IS NOT NULL
	DROP TABLE silver.marketing_spend;
GO

CREATE TABLE silver.marketing_spend (
	month_start_date DATE,
	[platform] NVARCHAR(50),
	spend NUMERIC(10,2),
	impressions INT,
	clicks INT,
	conversions INT,
	revenue_attributed NUMERIC(10,2),
	cpc NUMERIC(10,2),
	cpa NUMERIC(10,2),
	roas NUMERIC(10,2),
	create_date DATETIME2 DEFAULT GETDATE()
);
GO