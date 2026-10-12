# DataCo Delivery Performance Analysis

How big is the late-delivery problem at DataCo, where does it come from, and what should change? This project answers that with PostgreSQL, Excel and Power BI, using the public DataCo Smart Supply Chain dataset (180,519 order lines, Jan 2015 to Jan 2018).

## Answer in brief

**57.3% of orders arrive late (36,048 of 62,897), and the cause is the promise, not the carrier network.** The shipping mode sets the promised delivery time, and for First Class and Second Class that promise is shorter than DataCo actually delivers.

- First Class promises 1 day and always takes 2: 100% late.
- Second Class promises 2 days and takes 2 to 6: 80% late.
- Standard Class promises 4 days and is 40% late. Same Day is 48% late.
- Month, region and product category do not explain it. The rate sits at 55-60% every month, and the nine largest categories are all 56.9% to 57.6% late.
- Late orders carry $20.1M in sales and $2.14M in profit (57% of sales, 56% of profit).

**Recommendation:** reset promised days to match actual delivery times. Adding 1 day to every promise cuts the late rate from 57.3% to 23.7%; adding 2 days cuts it to 7.8%. Full findings, recommendations and limits are in [`FINDINGS.md`](FINDINGS.md).

## Deliverables

| File | What it is |
|---|---|
| [`FINDINGS.md`](FINDINGS.md) | Executive summary, findings, recommendations, limits |
| [`powerbi/DataCo_Delivery_Performance_Analysis.pdf`](powerbi/DataCo_Delivery_Performance_Analysis.pdf) | 3-page dashboard export (view without Power BI) |
| [`powerbi/DataCo_Delivery_Performance.pbix`](powerbi/DataCo_Delivery_Performance.pbix) | Interactive Power BI report (needs Power BI Desktop) |
| [`excel/03_Analysis_Workbook.xlsx`](excel/03_Analysis_Workbook.xlsx) | Summary and KPI tabs, every figure a formula, with reconciliation checks |
| [`excel/issues_log.xlsx`](excel/issues_log.xlsx) | Data issues and decisions, with the reason and the file that fixes each |
| [`sql/`](sql) | Load, profile, clean, model and KPI queries |

## Dashboard

1. **Executive Overview**: headline KPIs, monthly late rate, slicers for year, market and shipping mode.
2. **Promise vs Reality**: promised vs actual days by shipping mode, and the distribution of delay in days.
3. **Where It Breaks**: late rate by region and shipping mode, and by product category.

## Method

PostgreSQL, in three schemas:

- `raw`: the CSV loaded as text, never edited
- `clean`: typed columns, trimmed text, countries translated to English, personal data dropped
- `mart`: one row per non-canceled order (62,897 orders), plus order lines and dimension tables

Excel holds the analysis tabs and checks; Power BI (Import mode, DAX measures on a star schema) holds the dashboard. Every cleaning and exclusion decision is recorded in `excel/issues_log.xlsx`.

## Folder structure

    sql/
      01_load.sql          load the raw CSV
      02_profile.sql       profile queries, each with Saw / Means / Do notes
      03_country_map.sql   Spanish to English country lookup
      04_clean.sql         clean.order_lines
      05_model.sql         mart fact and dimension tables
      06_kpis.sql          late rate, monthly trend, shipping mode, promise test, what-if
    excel/
      03_Analysis_Workbook.xlsx
      issues_log.xlsx
    powerbi/
      DataCo_Delivery_Performance.pbix
      DataCo_Delivery_Performance_Analysis.pdf
      DataCo_Theme.json

## How to run

1. Download the dataset from Kaggle (DataCo Smart Supply Chain for Big Data Analysis) and save the CSV outside the repository. The data is not included here.
2. Create a PostgreSQL 15+ database and the schemas `raw`, `clean` and `mart`.
3. Edit the file path in `01_load.sql`, then run the files in order, 01 to 06.

## Definitions

- Order grain: KPIs are calculated per order, not per order line.
- Late: Delivery Status is "Late delivery".
- Excluded: canceled and suspected-fraud orders (7,754 lines).

## Limits

Public synthetic data, no carrier or cost data, canceled and suspected-fraud orders excluded, categories counted by lines. The what-if changes the promise, not the performance. See `FINDINGS.md` for more.

Source: Constante, Silva & Pereira (2019), Mendeley Data.
