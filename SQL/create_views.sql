CREATE VIEW analytics.vw_sales_by_region AS 
SELECT 
    region,
    FORMAT(order_date, 'yyyy-MM') year_month,
    SUM(revenue) total_revenue,
    COUNT(order_id) total_orders,
    AVG(revenue) avg_order_value
FROM staging.silver_sales
GROUP BY region, FORMAT(order_date, 'yyyy-MM');

GO