# DataCo Delivery Performance Analysis

How big is the late-delivery problem at DataCo, where does it come from, and what should change? This project answers that with SQL, Excel and Power BI, using the public DataCo Smart Supply Chain dataset (180,519 order lines, 2015 to early 2018).

Status: in progress. The SQL work through the first KPIs is done; the Excel workbook, Power BI dashboard and findings summary are next.

## Method

PostgreSQL, in three schemas:

- `raw`: the CSV loaded as text, never edited
- `clean`: typed columns, trimmed text, countries translated to English, personal data dropped
- `mart`: one row per non-canceled order (62,897 orders), plus order lines and dimension tables

Every cleaning and exclusion decision is recorded in `excel/issues_log.xlsx` with the reason and the file that fixes it.

## Folder structure

    sql/
      01_load.sql          load the raw CSV
      02_profile.sql       profile queries, each with Saw / Means / Do notes
      03_country_map.sql   Spanish to English country lookup
      04_clean.sql         clean.order_lines
      05_model.sql         mart fact and dimension tables
      06_kpis.sql          late rate, monthly trend, shipping mode
    excel/
      issues_log.xlsx      data issues and decisions

## How to run

1. Download the dataset from Kaggle (DataCo Smart Supply Chain for Big Data Analysis) and save the CSV outside the repository. The data is not included here.
2. Create a PostgreSQL 15+ database and the schemas `raw`, `clean` and `mart`.
3. Edit the file path in `01_load.sql`, then run the files in order, 01 to 06.

## Definitions

- Order grain: KPIs are calculated per order, not per order line.
- Late: Delivery Status is "Late delivery".
- Excluded: canceled and suspected-fraud orders (7,754 lines).

## Limits

Public synthetic data, no carrier or cost data, canceled and suspected-fraud orders excluded, categories counted by lines.

Source: Constante, Silva & Pereira (2019), Mendeley Data.