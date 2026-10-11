-- 04_clean.sql
-- Project 1: DataCo delivery performance
-- Stage 4: clean table, one row per order line (raw table is never edited)
-- Fixes: Issues Log #3 (stray spaces), #7 (country in English), #12 (dates as text),
--        #13 (PII left out), #14 (unused columns left out)

DROP TABLE IF EXISTS clean.order_lines;
CREATE TABLE clean.order_lines AS
WITH typed AS (
    SELECT
        s."Order Id"::int                                              AS order_id,
        s."Order Item Id"::int                                         AS order_item_id,
        to_timestamp(s."order date (DateOrders)",
                     'MM/DD/YYYY HH24:MI')::timestamp                  AS order_ts,
        to_timestamp(s."shipping date (DateOrders)",
                     'MM/DD/YYYY HH24:MI')::timestamp                  AS shipping_ts,
        s."Days for shipping (real)"::int                              AS days_real,
        s."Days for shipment (scheduled)"::int                         AS days_sched,
        s."Late_delivery_risk"::int                                    AS late_delivery_risk,
        regexp_replace(TRIM(s."Delivery Status"), '\s+', ' ', 'g')     AS delivery_status,
        regexp_replace(TRIM(s."Order Status"),    '\s+', ' ', 'g')     AS order_status,
        regexp_replace(TRIM(s."Shipping Mode"),   '\s+', ' ', 'g')     AS shipping_mode,
        regexp_replace(TRIM(s."Market"),          '\s+', ' ', 'g')     AS market,
        regexp_replace(TRIM(s."Order Region"),    '\s+', ' ', 'g')     AS order_region,
        COALESCE(m.country_en,
                 regexp_replace(TRIM(s."Order Country"), '\s+', ' ', 'g')) AS order_country,
        regexp_replace(TRIM(s."Order State"),     '\s+', ' ', 'g')     AS order_state,
        regexp_replace(TRIM(s."Order City"),      '\s+', ' ', 'g')     AS order_city,
        regexp_replace(TRIM(s."Category Name"),   '\s+', ' ', 'g')     AS category_name,
        regexp_replace(TRIM(s."Department Name"), '\s+', ' ', 'g')     AS department_name,
        s."Order Item Quantity"::int                                   AS quantity,
        s."Sales"::numeric(12,2)                                       AS sales,
        s."Order Profit Per Order"::numeric(12,2)                      AS profit
    FROM raw.stg_dataco AS s
    LEFT JOIN clean.country_map AS m
           ON s."Order Country" = m.country_raw
)
SELECT
    t.*,
    t.days_real - t.days_sched              AS delay_days,
    t.delivery_status = 'Late delivery'     AS is_late,
    t.delivery_status = 'Shipping canceled' AS is_canceled
FROM typed AS t;

-- Clean table check
-- Saw: 180,519 lines, the same as raw.stg_dataco.
-- Means: cleaning and the country join neither lost nor duplicated any line.
-- Do: nothing. Continue with the proof checks below.

SELECT COUNT(*) FROM clean.order_lines;

-- Clean table proof
-- Saw: 180,519 lines; 0 null countries; 0 null dates; is_late matches the original flag on
--      all lines; 7,754 canceled; 98,977 late; 23 regions with 0 untrimmed names.
-- Means: the clean table has every raw line, each with a country, valid dates, and tidy
--        text, and the late and canceled counts agree with the profile.
-- Do: nothing. Mark Issues Log #3, #12, #13, #14 as fixed in 04_clean.sql.

SELECT COUNT(*)                                                   AS total_lines,
       COUNT(*) FILTER (WHERE order_country IS NULL)              AS null_country,
       COUNT(*) FILTER (WHERE order_ts IS NULL
                           OR shipping_ts IS NULL)                AS null_dates,
       COUNT(*) FILTER (WHERE is_late <> (late_delivery_risk = 1)) AS late_mismatch,
       COUNT(*) FILTER (WHERE is_canceled)                        AS canceled_lines,
       COUNT(*) FILTER (WHERE is_late)                            AS late_lines,
       COUNT(DISTINCT order_region)                               AS regions,
       COUNT(*) FILTER (WHERE order_region <> TRIM(order_region)) AS region_untrimmed
FROM clean.order_lines;