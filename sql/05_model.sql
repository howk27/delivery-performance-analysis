-- 05_model.sql
-- Project 1: DataCo delivery performance
-- Stage 5: model. KPIs are per order, so build an order-level table plus small
-- dimension tables from clean.order_lines. Output goes to the mart schema.
-- Rerunnable: every table is dropped before it is created.

CREATE SCHEMA IF NOT EXISTS mart;


-- Fact table: one row per non-canceled order
-- Canceled and suspected fraud lines are left out (Issues Log #4).
-- MAX() is safe for order-level columns, Query 7 found 0 conflicting orders (Issues Log #6).
DROP TABLE IF EXISTS mart.fact_orders;
CREATE TABLE mart.fact_orders AS
SELECT order_id,
       MAX(order_ts) AS order_ts,
       MAX(shipping_ts) AS shipping_ts,
       MAX(shipping_mode) AS shipping_mode,
       MAX(market) AS market,
       MAX(order_region) AS order_region,
       MAX(order_country) AS order_country,
       MAX(days_real) AS days_real,
       MAX(days_sched) AS days_sched,
       MAX(delay_days) AS delay_days,
       BOOL_OR(is_late) AS is_late,
       COUNT(*) AS line_count,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM clean.order_lines
WHERE NOT is_canceled
GROUP BY order_id;

ALTER TABLE mart.fact_orders ADD PRIMARY KEY (order_id);


-- Fact table: one row per non-canceled order line (for category questions)
DROP TABLE IF EXISTS mart.fact_order_lines;
CREATE TABLE mart.fact_order_lines AS
SELECT order_item_id,
       order_id,
       category_name,
       department_name,
       quantity,
       sales,
       profit,
       is_late
FROM clean.order_lines
WHERE NOT is_canceled;

ALTER TABLE mart.fact_order_lines ADD PRIMARY KEY (order_item_id);


-- Model check: do the fact tables reconcile with clean.order_lines?
-- Saw: 62,897 orders in fact_orders and 62,897 distinct non-canceled orders in
--      clean.order_lines; sales 35,214,428.98 on both sides; 172,765 lines in fact_order_lines.
-- Means: grouping to one row per order lost no order and no sales. 62,897 orders remain
--        after removing canceled and suspected fraud (65,752 in total).
-- Do: nothing. Issues Log #1, #4, #6, #10 fixed in 05_model.sql.
SELECT (SELECT COUNT(*) FROM mart.fact_orders) AS fact_orders_rows,
       (SELECT COUNT(DISTINCT order_id) FROM clean.order_lines WHERE NOT is_canceled) AS expected_orders,
       (SELECT SUM(total_sales) FROM mart.fact_orders) AS fact_sales,
       (SELECT SUM(sales) FROM clean.order_lines WHERE NOT is_canceled) AS clean_sales,
       (SELECT COUNT(*) FROM mart.fact_order_lines) AS fact_line_rows,
       (SELECT COUNT(*) FROM clean.order_lines WHERE NOT is_canceled) AS expected_lines;


-- Dimension: shipping mode
DROP TABLE IF EXISTS mart.dim_shipping_mode;
CREATE TABLE mart.dim_shipping_mode AS
SELECT DISTINCT shipping_mode
FROM mart.fact_orders;

ALTER TABLE mart.dim_shipping_mode ADD PRIMARY KEY (shipping_mode);


-- Dimension: date, every day from 2015 to 2018
DROP TABLE IF EXISTS mart.dim_date;
CREATE TABLE mart.dim_date AS
SELECT d::date AS date_key,
       EXTRACT(YEAR FROM d)::int AS year,
       EXTRACT(MONTH FROM d)::int AS month_num,
       TO_CHAR(d, 'Mon') AS month_name,
       date_trunc('month', d)::date AS month_start
FROM generate_series('2015-01-01'::date, '2018-12-31'::date, interval '1 day') AS d;

ALTER TABLE mart.dim_date ADD PRIMARY KEY (date_key);


-- Dimension: geography, one row per market + region + country
-- Country alone is not unique, the United States sits in 4 regions (Issues Log #9).
DROP TABLE IF EXISTS mart.dim_geography;
CREATE TABLE mart.dim_geography AS
SELECT ROW_NUMBER() OVER (ORDER BY market, order_region, order_country) AS geo_id,
       market, order_region, order_country
FROM (SELECT DISTINCT market, order_region, order_country
      FROM mart.fact_orders) AS g;

ALTER TABLE mart.dim_geography ADD PRIMARY KEY (geo_id);


-- Test: does each category belong to exactly one department?
-- Saw: 1 category (Electronics) sits under 2 departments, Outdoors (2,029 lines) and
--      Footwear (1,127 lines).
-- Means: department is not reliable for a category in this data, so category_name
--        cannot carry a department.
-- Do: dim_product holds category only. Department is not used in any KPI. Logged as #15.
SELECT category_name, COUNT(DISTINCT department_name) AS departments
FROM clean.order_lines
GROUP BY 1
HAVING COUNT(DISTINCT department_name) > 1;


-- Dimension: product, one row per category
DROP TABLE IF EXISTS mart.dim_product;
CREATE TABLE mart.dim_product AS
SELECT DISTINCT category_name
FROM mart.fact_order_lines;

ALTER TABLE mart.dim_product ADD PRIMARY KEY (category_name);


-- Keys on fact_orders: a date column and the geography key
ALTER TABLE mart.fact_orders ADD COLUMN order_date date;
ALTER TABLE mart.fact_orders ADD COLUMN geo_id bigint;

UPDATE mart.fact_orders AS f
SET order_date = f.order_ts::date,
    geo_id = g.geo_id
FROM mart.dim_geography AS g
WHERE f.market = g.market
  AND f.order_region = g.order_region
  AND f.order_country = g.order_country;
-- should update 62,897 rows, one per order


-- Keys check: does every key in the facts exist in its dimension?
-- Saw: 0 | 0 | 0 | 0 (no_mode, no_date, no_geo, no_product).
-- Means: every order and line links to a shipping mode, date, geography and category,
--        so no rows will be dropped by the Power BI relationships.
-- Do: nothing. Issues Log #9 and #15 fixed in 05_model.sql.
SELECT (SELECT COUNT(*) FROM mart.fact_orders AS f
        LEFT JOIN mart.dim_shipping_mode AS d ON f.shipping_mode = d.shipping_mode
        WHERE d.shipping_mode IS NULL) AS no_mode,
       (SELECT COUNT(*) FROM mart.fact_orders AS f
        LEFT JOIN mart.dim_date AS d ON f.order_date = d.date_key
        WHERE d.date_key IS NULL) AS no_date,
       (SELECT COUNT(*) FROM mart.fact_orders AS f
        LEFT JOIN mart.dim_geography AS d ON f.geo_id = d.geo_id
        WHERE d.geo_id IS NULL) AS no_geo,
       (SELECT COUNT(*) FROM mart.fact_order_lines AS f
        LEFT JOIN mart.dim_product AS d ON f.category_name = d.category_name
        WHERE d.category_name IS NULL) AS no_product;


-- Extra model checks: profit, late rate and dimension sizes
-- Expect: fact_profit = clean_profit, late_pct_orders close to 57, modes = 4
-- Saw: profit 3,806,420.63 on both sides; 57.3% of orders late; 4 shipping modes;
--      167 geography rows; 50 categories.
-- Means: the order table carries the same money as the clean table, and the late rate
--        matches the line-level result from Query 4 (57.3%).
-- Do: nothing. Stage 5 is done, next is 06_kpis.sql.
SELECT (SELECT SUM(total_profit) FROM mart.fact_orders) AS fact_profit,
       (SELECT SUM(profit) FROM clean.order_lines WHERE NOT is_canceled) AS clean_profit,
       (SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1)
        FROM mart.fact_orders) AS late_pct_orders,
       (SELECT COUNT(*) FROM mart.dim_shipping_mode) AS modes,
       (SELECT COUNT(*) FROM mart.dim_geography) AS geo_rows,
       (SELECT COUNT(*) FROM mart.dim_product) AS categories;