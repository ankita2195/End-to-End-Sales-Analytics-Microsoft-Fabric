CREATE TABLE [analytics].[fact_sales] (
    [order_id]       VARCHAR (8000) NULL,
    [order_date_key] INT            NULL,
    [customer_key]   BIGINT         NULL,
    [product_key]    BIGINT         NULL,
    [region_key]     BIGINT         NULL,
    [revenue]        FLOAT (53)     NULL,
    [quantity]       INT            NULL,
    [revenue_usd]    FLOAT (53)     NULL
);


GO