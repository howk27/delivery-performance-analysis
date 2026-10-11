-- 01_load.sql
DROP TABLE IF EXISTS raw.stg_dataco;

CREATE TABLE raw.stg_dataco (
    "Type" TEXT, "Days for shipping (real)" TEXT, "Days for shipment (scheduled)" TEXT,
    "Benefit per order" TEXT, "Sales per customer" TEXT, "Delivery Status" TEXT,
    "Late_delivery_risk" TEXT, "Category Id" TEXT, "Category Name" TEXT,
    "Customer City" TEXT, "Customer Country" TEXT, "Customer Email" TEXT,
    "Customer Fname" TEXT, "Customer Id" TEXT, "Customer Lname" TEXT,
    "Customer Password" TEXT, "Customer Segment" TEXT, "Customer State" TEXT,
    "Customer Street" TEXT, "Customer Zipcode" TEXT, "Department Id" TEXT,
    "Department Name" TEXT, "Latitude" TEXT, "Longitude" TEXT, "Market" TEXT,
    "Order City" TEXT, "Order Country" TEXT, "Order Customer Id" TEXT,
    "order date (DateOrders)" TEXT, "Order Id" TEXT, "Order Item Cardprod Id" TEXT,
    "Order Item Discount" TEXT, "Order Item Discount Rate" TEXT, "Order Item Id" TEXT,
    "Order Item Product Price" TEXT, "Order Item Profit Ratio" TEXT,
    "Order Item Quantity" TEXT, "Sales" TEXT, "Order Item Total" TEXT,
    "Order Profit Per Order" TEXT, "Order Region" TEXT, "Order State" TEXT,
    "Order Status" TEXT, "Order Zipcode" TEXT, "Product Card Id" TEXT,
    "Product Category Id" TEXT, "Product Description" TEXT, "Product Image" TEXT,
    "Product Name" TEXT, "Product Price" TEXT, "Product Status" TEXT,
    "shipping date (DateOrders)" TEXT, "Shipping Mode" TEXT
);

-- HEADER MATCH stops the load if the CSV headers don't match the table exactly.
\COPY raw.stg_dataco FROM 'C:/data/dataco/DataCoSupplyChainDataset.csv' WITH (FORMAT csv, HEADER MATCH, ENCODING 'WIN1252')

-- Validate: expect about 180,519 rows. Record the result in your issues log.
SELECT COUNT(*)                        AS total_rows,
       COUNT(DISTINCT "Order Id")      AS distinct_orders,
       COUNT(DISTINCT "Order Item Id") AS distinct_order_items
FROM raw.stg_dataco;
