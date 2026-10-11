-- KPI 1: how big is the late-delivery problem?
-- Saw: 36,048 of 62,897 orders were late (57.3%).
-- Means: More than half of all non-canceled orders arrived after the promised date, so lateness is the normal outcome, not an exception.
-- Do: Use 57.3% as the headline rate. Next, check whether it changes over time (KPI 2). No Issues Log row, since nothing was wrong with the data.
SELECT COUNT(*) AS orders,
       COUNT(*) FILTER (WHERE is_late) AS late_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1) AS late_pct
FROM mart.fact_orders;


-- KPI 2: late rate by month, with the change from the previous month
-- Saw: 37 months, Jan 2015 to Jan 2018; the 37 monthly counts add up to 62,897 orders. Late rate stays between 55.0% (Apr 2017) and 59.9% (Jun 2016) with no upward or downward trend. Largest month-to-month swing is -4.4 points (Jul 2016). Orders per month rise from about 1,650 to about 2,000 from Oct 2017; the late rate does not change.
-- Means: Lateness is a steady 57% in every month, so it is not seasonal and not getting worse, and more orders did not make it worse.
-- Do: Treat the late rate as structural and look at what differs inside the orders (mode, region, category). Do not chase single-month swings. Issues log #16.
    WITH monthly AS (SELECT date_trunc('month', order_ts)::date AS month,
           COUNT(*) AS orders,
           COUNT(*) FILTER (WHERE is_late) AS late_orders,
           ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1) AS late_pct
    FROM mart.fact_orders
    GROUP BY 1
)
SELECT month, orders, late_orders, late_pct,
       ROUND(late_pct - LAG(late_pct) OVER (ORDER BY month), 1) AS change_pts
FROM monthly
ORDER BY month;


-- KPI 3: shipping mode, promise vs reality
-- Saw: 4 modes, 62,897 orders. First Class: 100.0% late, promised 1.00 day, actual 2.00. Second Class: 80.0% late, promised 2.00, actual 4.00. Same Day: 48.4% late, promised 0.00, actual 0.48. Standard Class (37,632 orders, 60% of the total): 39.8% late, promised 4.00, actual 3.99.
-- Means: Standard Class delivers on its promise on average, while First Class and Second Class take about twice as long as they promise, so the late rate depends mostly on the shipping mode.
-- Do: Treat shipping mode as the main driver and look at region, category and money next. Add no Issues Log row (no data problem); keep the averages in the findings as promised vs actual days.
SELECT shipping_mode,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1) AS late_pct,
       ROUND(AVG(days_sched), 2) AS avg_promised_days,
       ROUND(AVG(days_real), 2) AS avg_actual_days,
       ROUND(AVG(delay_days), 2) AS avg_delay_days
FROM mart.fact_orders
GROUP BY 1
ORDER BY late_pct DESC;


-- Check: orders in Oct 2017 to Jan 2018, before and after removing canceled orders
-- Saw: 8,403 distinct orders in the clean table for Oct 2017 to Jan 2018; 8,043 kept and 360 canceled or suspected fraud (8,403 - 8,043 = 360).
-- Means: The 8,403 in Issues Log #1 counts orders before exclusions, and the 8,043 in #16 counts orders after. The two rows agree.
-- Do: Keep both rows as written. No change to the data. Use 8,043 for any volume figure in the report, since KPIs exclude canceled orders.
SELECT COUNT(DISTINCT order_id) AS all_orders,
       COUNT(DISTINCT order_id) FILTER (WHERE NOT is_canceled) AS kept_orders,
       COUNT(DISTINCT order_id) FILTER (WHERE is_canceled) AS canceled_orders
FROM clean.order_lines
WHERE order_ts >= '2017-10-01' AND order_ts < '2018-02-01';


-- KPI 4: late rate by region within each shipping mode (cells under 30 orders hidden)
-- Saw: 87 mode-and-region cells. First Class is 100.0% late in all 22 regions. Second Class runs 76.5% to 85.7% and Same Day 37.0% to 53.8%, but the extremes are small cells (42 to 65 orders). Standard Class runs 33.0% (Canada, 176 orders) to 44.3% (Central Africa, 318); among cells with 1,000+ orders it is only 36.7% to 41.1%.
-- Means: Inside each shipping mode the late rate is about the same in every region, so where the order goes explains almost nothing, while the mode explains a 60-point gap.
-- Do: Treat region as a minor factor and keep shipping mode as the main driver. Do not single out any region in the findings. No Issues Log row (no data problem).
SELECT shipping_mode,
       order_region,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1) AS late_pct
FROM mart.fact_orders
GROUP BY 1, 2
HAVING COUNT(*) >= 30
ORDER BY shipping_mode, late_pct DESC;


-- KPI 5: late rate by category, counted in lines (categories under 100 lines hidden)
-- Saw: 47 categories shown (3 hidden, 191 lines in total). The nine largest categories (10,000+ lines each, about 87% of all lines) run from 56.9% to 57.6% late. The extremes are small: Lacrosse 62.6% (329 lines) and Men's Golf Clubs 49.3% (274 lines); the full range is 49.3% to 62.6%.
-- Means: Every large category is late about 57% of the time, so what the customer ordered makes no real difference; the high and low ends are small categories where a few lines move the rate.
-- Do: Treat category as a minor factor and do not single out any category in the findings. Shipping mode stays the main driver. No Issues Log row (no data problem); the report says "lines" for categories.
SELECT category_name,
       COUNT(*) AS lines,
       ROUND(100.0 * COUNT(*) FILTER (WHERE is_late) / COUNT(*), 1) AS late_pct
FROM mart.fact_order_lines
GROUP BY 1
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;


-- KPI 6: sales and profit on late vs on-time orders
-- Saw: 36,048 late orders carry 20,126,394.88 in sales (57.2% of the total) and 2,140,051.68 in profit (56.2%). 26,849 on-time orders carry 15,088,034.10 in sales and 1,666,368.95 in profit. Totals match the anchors (62,897 orders, 35,214,428.98 sales, 3,806,420.63 profit). Average sales per order is about 558 late vs 562 on time; profit margin is 10.6% late vs 11.0% on time.
-- Means: More than half of the business value (20.1 million in sales, 2.1 million in profit) sits on orders that arrive late, and late orders are no bigger or smaller than on-time ones.
-- Do: Use 20.1 million in sales and 2.14 million in profit as the exposure figure in the findings, described as value on late orders, not lost revenue. Do not claim late orders are less profitable (0.4-point margin gap). No Issues Log row (no data problem).
SELECT is_late,
       COUNT(*) AS orders,
       ROUND(SUM(total_sales), 2) AS sales,
       ROUND(SUM(total_profit), 2) AS profit,
       ROUND(100.0 * SUM(total_sales) / SUM(SUM(total_sales)) OVER (), 1) AS pct_of_sales,
       ROUND(100.0 * SUM(total_profit) / SUM(SUM(total_profit)) OVER (), 1) AS pct_of_profit
FROM mart.fact_orders
GROUP BY is_late
ORDER BY is_late DESC;