# End-to-End Sales Analytics Using Microsoft Fabric

An end-to-end sales analytics project built using **Microsoft Fabric**, demonstrating data ingestion, medallion architecture, PySpark transformations, dimensional modelling, data warehousing, semantic modelling, and Power BI reporting.

## Project Overview

This project implements an end-to-end sales analytics workflow using Microsoft Fabric. It covers the movement of sales data from its source through different data processing and modelling stages, ultimately making it available for reporting through a Fabric semantic model and Power BI.

The primary focus is on exploring Microsoft Fabric's data engineering and analytics capabilities, including Lakehouse, Data Factory, Dataflows Gen2, Notebooks, Fabric Warehouse, and Direct Lake.

### Tech Stack

- **Microsoft Fabric:** Lakehouse, Data Factory, Dataflows Gen2, Notebooks, Warehouse, Semantic Model
- **Languages:** PySpark, SQL, DAX
- **Data Storage:** Delta Lake
- **Reporting:** Power BI

## 1. Architecture

The project follows an end-to-end architecture covering data ingestion, transformation, dimensional modelling, warehousing, and reporting.

<img width="767" height="862" alt="Screenshot 2026-09-27 152249" src="https://github.com/user-attachments/assets/9664fc25-53ae-4c48-ab7f-1d083ee3c4b2" />


## 2. Data Ingestion - Fabric Data Factory

The source dataset, `sales_data.csv`, was ingested from an HTTP source using a Fabric Data Factory pipeline named `pl_ingest_sales`.

The pipeline contains the following activities:

1. `CopyRawSalesCSV`
2. `CopyDatatoDelta`
3. `TransformBronzetoSilver`
4. `Build_Gold_layer`
5. `transformSilvertoWarehouse`

These activities orchestrate the ingestion and transformation workflow across the Lakehouse and Warehouse.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/403e6aaf-d93e-43d5-93e7-1f8f61abeb8e" />


## 3. Lakehouse - Medallion Architecture

A Fabric Lakehouse named `lh_sales` was used to store and process the sales data using the Bronze, Silver, and Gold layers.

### Bronze Layer - Raw Data Ingestion

The raw CSV file was loaded into the Lakehouse using a PySpark notebook named `nb_load_to_delta`.

Implementation:
- Read the CSV file using PySpark.
- Enabled header recognition and schema inference.
- Stored the ingested data as a Delta table named `bronze_sales`.

The Bronze layer retains the initially ingested data before the subsequent transformation steps.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/970eb1ff-ba23-4cae-bc38-a9b114163655" />

### Silver Layer - Data Transformation

The Bronze data was transformed using the notebook `nb_transform_bronze_to_silver`.

The transformations included:

- **Row filtering:** Retained records with `Active` status and positive revenue.
- **Column standardisation:** Renamed columns using snake_case naming conventions.
- **Data type conversion:** Converted `order_date` into DateType.
- **Calculated column:** Created `revenue_usd` using a fixed conversion rate of 1 USD = ₹83.
- **Delta table creation:** Saved the transformed data as `silver_sales`.

The resulting Silver table provides a standardised dataset for downstream analytics.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/a3d148c7-6d88-4382-859f-dfbceb57527a" />

### Gold Layer - Aggregated Sales Data

The Gold layer was created using the notebook `nb_build_gold_layer`, which reads the `silver_sales` Delta table.

The data was grouped by:
- Region
- Year-Month

The following metrics were calculated:

- Total Revenue
- Total Orders
- Average Order Value

The aggregated output was stored as a Delta table named `gold_sales_summary`.

Its grain is one record per region and year-month combination.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/cc67db6b-3058-4f04-a704-1a4c7c39ad54" />


## 4. Dataflows Gen2

Dataflows Gen2 was used for data preparation, specifically:

- Changing column data types.
- Filtering rows.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/a1147cfe-7f5e-4a3a-831a-b6ee2a70ff48" />


## 5. Dimensional Modelling - PySpark Notebooks

Dimension and fact tables were created separately using PySpark notebooks. The dimension-building notebook was executed independently rather than as an activity in the pipeline.

### Dimension Tables

Three dimension tables were created from distinct records in the Silver dataset:

| Table | Attributes |
|---|---|
| `dim_customer` | customer_key, customer_name, region |
| `dim_product` | product_key, product_category |
| `dim_region` | region_key, region |

Surrogate keys were assigned using PySpark's `monotonically_increasing_id()` function.

The customer dimension uses distinct combinations of customer name and region.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/80ab8d18-84a0-4584-9a05-94ac72772486" />

### Fact Table

The `fact_sales` table was created by joining `silver_sales` with the three dimension tables to retrieve their corresponding surrogate keys.

A date surrogate key (`order_date_key`) was also generated in YYYYMMDD integer format.

The final fact table contains:

- order_id
- order_date_key
- customer_key
- product_key
- region_key
- revenue
- quantity
- revenue_usd

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/db224f3f-52b2-4e06-9d9d-c672c2f1d2aa" />


## 6. Fabric Warehouse - SQL-Based Data Warehousing

A Fabric Warehouse named `wh_sales` was used to implement the dimensional model.

The dimension and fact tables created in the Lakehouse were brought into the Warehouse using SQL `CREATE TABLE AS SELECT (CTAS)` statements.

The Warehouse contains:

- `dim_customer`
- `dim_product`
- `dim_region`
- `dim_date`
- `fact_sales`

### Date Dimension

The `dim_date` table was created directly in the Warehouse using SQL.

It includes:

- Date key (YYYYMMDD)
- Full date
- Year
- Month number
- Month name
- Quarter
- Day of week
- Weekend indicator

The date dimension was populated for the period from January 2023 to December 2024.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/de3ae679-8889-418e-bb8c-d9615776ecc2" />


### Additional SQL Development

The project also included SQL development involving:

- A stored procedure: `analytics.usp_GetTopCustomers`, designed to retrieve the top customers based on revenue, with a configurable number of results.
- A view: `analytics.vw_sales_by_region`, designed to aggregate sales by region and year-month.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8127bad2-1bc4-488d-96db-9b36182cbd79" />


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d1cc19b8-ec34-4394-84b9-dcae447b77ab" />


## 7. Semantic Model - Star Schema

A Fabric semantic model named `SM_Sales_Analytics` was created using the Warehouse tables.

The dimensional model consists of:

- **Fact table:** `fact_sales`
- **Dimension tables:** `dim_customer`, `dim_product`, `dim_region`, `dim_date`

Relationships were established between the fact table and the corresponding dimensions using their keys.

The semantic model also includes DAX measures for sales and order analysis.

Measures created:

- Average Order Value
- Average Quantity per Order
- Average Revenue per Order
- Rank
- Total Customers
- Total Orders
- Total Quantity Sold
- Total Revenue
- Total Revenue (USD)

The semantic model was used as the data source for the Power BI report through a **Direct Lake connection**.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/de41c9ef-f9f3-4879-bebd-abf97ad95417" />


## 8. Power BI - Sales Analytics Report

A Power BI report named `Sales Report` was developed using the Fabric semantic model.

The report contains a single page, **Sales Analytics Overview**, with the following components:

### Key Performance Indicators
- Total Revenue
- Total Revenue (USD)
- Total Orders
- Total Quantity Sold
- Average Revenue per Order
- Average Quantity per Order

### Visualisations
- Monthly Revenue and Orders Trend
- Orders by Product Category
- Revenue by Region
- Orders by Region
- Total Revenue by Category
- Quantity Sold by Product Category
- Top 10 Customers by Revenue

Date, Month, Quarter, and Year slicers enable users to explore the report across different time periods.

<img width="1253" height="787" alt="image" src="https://github.com/user-attachments/assets/cd6a3768-4377-434f-ac70-29a0bbdacdc3" />


## 9. Key Business Insights

The report highlights the following observations:

- **Product Performance:** Electronics generates the highest revenue, while Office Supplies records the highest quantity sold.
- **Regional Performance:** North and West contribute approximately ₹3.6M each, followed by East at ₹3.5M and South at ₹2.9M.
- **Monthly Performance:** October records the highest monthly revenue at approximately ₹1.4M, while September records the lowest at approximately ₹0.9M.
- **Customer Performance:** Vivek Chopra ranks first among customers, contributing approximately ₹533K in revenue.

*Values are rounded as displayed in the Power BI report.*

## 10. Repository Structure

```text
Sales-Analytics-Microsoft-Fabric/
│
├── README.md
│
├── Architecture/
│   └── fabric_architecture.png
│
├── Screenshots/
│   ├── Data_Pipeline/
│   ├── Dataflows_Gen2/
│   ├── Fabric_Workspace/
│   ├── Lakehouse/
│   ├── PowerBI Report/
│   ├── Star_Schema/
│   └── Warehouse/
│
├── Notebooks/
│   ├── nb_load_to_delta.ipynb
│   ├── nb_transform_bronze_to_silver.ipynb
│   ├── nb_build_gold_layer.ipynb
│   └── nb_build_tables.ipynb
│
├── SQL/
│   ├── create_dim_customer.sql
│   ├── create_dim_date.sql
│   ├── create_dim_product.sql
│   ├── create_dim_region.sql
│   ├── create_fact_sales.sql
│   ├── create_views.sql
│   └── stored_procedure.sql
│
└── Dashboard/
    └── Sales_Report.pdf
```

## 11. Key Learnings

Through this project, I gained practical experience with:

- Building an end-to-end data pipeline in Microsoft Fabric.
- Working with Lakehouse architecture and Delta tables.
- Implementing Bronze, Silver, and Gold data layers.
- Performing data transformations using PySpark.
- Creating dimension and fact tables using surrogate keys.
- Implementing a star schema in Fabric Warehouse.
- Writing SQL queries, CTAS statements, stored procedures, and views.
- Building a Fabric semantic model with DAX measures.
- Connecting Power BI reports using Direct Lake.

