-- 02_profile.sql
-- Project 1: DataCo delivery performance
-- Stage 2: profile the raw table before changing anything
-- Table: raw.stg_dataco (every column is TEXT)


-- Query 1: how big is the table?
-- Expect: 180,519 lines, about 65,752 orders, about 2.75 lines per order
SELECT COUNT(*)                               AS total_lines,
       COUNT(DISTINCT "Order Id")             AS total_orders,
       ROUND(COUNT(*)::numeric / COUNT(DISTINCT "Order Id"), 2) AS lines_per_order
FROM raw.stg_dataco;


-- Query 2: distinct values and row counts for key text columns
-- Check: each result must add up to 180,519

-- Shipping Mode
SELECT "Shipping Mode", COUNT(*) AS lines
FROM raw.stg_dataco
GROUP BY 1
ORDER BY 2 DESC;

-- Delivery Status
SELECT "Delivery Status", COUNT(*) AS lines
FROM raw.stg_dataco
GROUP BY 1
ORDER BY 2 DESC;

-- Market
SELECT "Market", COUNT(*) AS lines
FROM raw.stg_dataco
GROUP BY 1
ORDER BY 2 DESC;


-- Query 3: rows (order lines) and orders per month
-- Finding: Jan 2015 to Sep 2017 about 5,200 lines and 1,750 orders a month.
-- From Oct 2017 lines = orders (1 line per order, was about 3).
-- Orders did not drop. Logged as Issues Log #1.
SELECT date_trunc('month',
                  to_timestamp("order date (DateOrders)",
                 'MM/DD/YYYY HH24:MI')) AS month,
       COUNT(*)   AS lines,
       COUNT(DISTINCT "Order Id")   AS orders
FROM raw.stg_dataco
GROUP BY 1
ORDER BY 1;

--Query 4: late flag consistency (3 definitions of late)

--Query 4a: how many lines are late by each definition? (flag, days rule, Delivery Status)
-- Saw: 5 combinations, each status has only one flag value (Late delivery = 1,
--      all others = 0).
--      Days rule agrees with the flag everywhere except Shipping canceled,
--      which splits 3,331 false / 4,423 true (7,754 canceled lines).
--      Lines add up to 180,519. 
-- Means: Delivery Status, the flag and the days rule are one definition of late.
--        Canceled lines are the exception: they never shipped, so their day counts are not real.
-- Do: define is_late from Delivery Status, canceled excluded from KPIs. Logged as Issues Log #2.

SELECT "Delivery Status",
       "Late_delivery_risk",
       "Days for shipping (real)"::int > "Days for shipment (scheduled)"::int AS days_say_late,
       COUNT(*) AS lines
FROM raw.stg_dataco
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

--Query 4b: which lines have the flag and the days rule disagreeing?
-- Saw: Only disagreement is Shipping canceled, flag 0, days say late: 4,423 lines. See 4a.
-- So for the other 172,765 non-canceled lines, the flag and the days rule agree on every line.

SELECT "Delivery Status",
       "Late_delivery_risk",
       "Days for shipping (real)"::int > "Days for shipment (scheduled)"::int AS days_say_late,
       COUNT(*) AS lines
FROM raw.stg_dataco
WHERE ("Late_delivery_risk"::int=1) <> ("Days for shipping (real)"::int > "Days for shipment (scheduled)"::int)
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;

-- Query 5: 

--Query 5a: how many lines per Order Region?
--Saw: 23 regions; lines add up to 180,519 and three names have stray spaces.
--Means: Region is a clean 23-value geography column apart from whitespace.
--Do: No action on the list itself; the spaces are logged as #3.

SELECT "Order Region", COUNT(*) AS lines
FROM raw.stg_dataco
GROUP BY 1
ORDER BY 2 DESC;

-- Query 5b: which Order Status values sit under Shipping canceled?
-- Saw: Shipping canceled = CANCELED 3,692 + SUSPECTED_FRAUD 4,062 = 7,754,
--      matching Query 4. Neither status appears under any other Delivery Status.
-- Means: Slightly over half are fraud flags (4,062 of 7,754, 52%)
-- Do: is_canceled from Delivery Status (identical set). In the report, call
--     them "canceled or suspected fraud". Logged as Issues Log #4.

SELECT "Order Status", "Delivery Status", COUNT(*)
FROM raw.stg_dataco
GROUP BY 1,2
ORDER BY 2,1;

-- Query 6: blanks and number formats in the columns the KPIs use

-- Saw: [0 in all 13 blank checks, 0 bad numbers in Sales, profit, quantity]
-- Means: the columns the KPIs use are complete and numeric.
-- Do: cast them in the clean step. Logged as Issues Log #5.

SELECT
  -- Part 1: blank = NULL or empty text. One count per column.
  COUNT(*) FILTER (WHERE "Order Id" IS NULL OR TRIM("Order Id") = '')                         AS order_id_blank,
  COUNT(*) FILTER (WHERE "order date (DateOrders)" IS NULL OR TRIM("order date (DateOrders)") = '') AS order_date_blank,
  COUNT(*) FILTER (WHERE "Shipping Mode" IS NULL OR TRIM("Shipping Mode") = '')               AS shipping_mode_blank,
  COUNT(*) FILTER (WHERE "Delivery Status" IS NULL OR TRIM("Delivery Status") = '')           AS delivery_status_blank,
  COUNT(*) FILTER (WHERE "Late_delivery_risk" IS NULL OR TRIM("Late_delivery_risk") = '')     AS late_flag_blank,
  COUNT(*) FILTER (WHERE "Days for shipping (real)" IS NULL OR TRIM("Days for shipping (real)") = '')           AS days_real_blank,
  COUNT(*) FILTER (WHERE "Days for shipment (scheduled)" IS NULL OR TRIM("Days for shipment (scheduled)") = '') AS days_sched_blank,
  COUNT(*) FILTER (WHERE "Order Country" IS NULL OR TRIM("Order Country") = '')               AS country_blank,
  COUNT(*) FILTER (WHERE "Market" IS NULL OR TRIM("Market") = '')                             AS market_blank,
  COUNT(*) FILTER (WHERE "Order Region" IS NULL OR TRIM("Order Region") = '')                 AS region_blank,
  COUNT(*) FILTER (WHERE "Category Name" IS NULL OR TRIM("Category Name") = '')               AS category_blank,
  COUNT(*) FILTER (WHERE "Sales" IS NULL OR TRIM("Sales") = '')                               AS sales_blank,
  COUNT(*) FILTER (WHERE "Order Profit Per Order" IS NULL OR TRIM("Order Profit Per Order") = '') AS profit_blank,
  -- Part 2: Text to number.
  COUNT(*) FILTER (WHERE "Sales" !~ '^-?[0-9]+(\.[0-9]+)?$')                                  AS sales_bad,
  COUNT(*) FILTER (WHERE "Order Profit Per Order" !~ '^-?[0-9]+(\.[0-9]+)?$')                 AS profit_bad,
  COUNT(*) FILTER (WHERE "Order Item Quantity" !~ '^[0-9]+$')                                 AS quantity_bad
FROM raw.stg_dataco;

-- Query 7: does every line of an order agree on the order-level columns?
-- Saw: 0 orders where any of the 8 columns has more than one value.
-- Means: every line of an order agrees on mode, day counts, date, status,
--        country, region and market, so collapsing lines into orders loses nothing.
-- Do: no repair needed. Build the order table with GROUP BY order_id and MAX().
--     Logged as Issues Log #6.

SELECT COUNT(*) FROM (
  SELECT "Order Id"
  FROM raw.stg_dataco
  GROUP BY "Order Id"
  HAVING COUNT(DISTINCT "Shipping Mode") > 1
      OR COUNT(DISTINCT "Days for shipping (real)") > 1
      OR COUNT(DISTINCT "Days for shipment (scheduled)") > 1
      OR COUNT(DISTINCT "order date (DateOrders)") > 1
      OR COUNT(DISTINCT "Delivery Status") > 1
      OR COUNT(DISTINCT "Order Country") > 1
      OR COUNT(DISTINCT "Order Region") > 1
      OR COUNT(DISTINCT "Market") > 1
) AS t;

-- Query 8: size of the geography problem

-- Saw: 164 countries (164 after trimming), 1,089 states, 3,597 cities.
--      Names like Alemania and Arabia Saudí are Spanish.
--      Only Estados Unidos sits in more than one region (4: East, South, Center
--      and West of USA), all in one market (USCA). Every other country has
--      one region and one market.
-- Means: country needs translating to English. Country is not a unique key for
--        region because the USA is split into four regions.
-- Do: translate Order Country with a lookup table. Keep Order State and Order City
--     as they are, because no KPI uses them. Do not key the geography table on
--     country alone. Logged as Issues Log #7, #8 and #9.

-- Query 8a: how many distinct countries, states and cities?
SELECT COUNT(DISTINCT "Order Country")        AS countries,
       COUNT(DISTINCT TRIM("Order Country"))  AS countries_trimmed,
       COUNT(DISTINCT "Order State")          AS states,
       COUNT(DISTINCT "Order City")           AS cities
FROM raw.stg_dataco;

-- Query 8b: the first 20 country names
SELECT DISTINCT "Order Country"
FROM raw.stg_dataco
ORDER BY 1
LIMIT 20;

-- Query 8c: does any country sit in more than one region or market?
SELECT "Order Country"
FROM raw.stg_dataco
GROUP BY "Order Country"
HAVING COUNT(DISTINCT "Order Region") > 1
    OR COUNT(DISTINCT "Market") > 1;

