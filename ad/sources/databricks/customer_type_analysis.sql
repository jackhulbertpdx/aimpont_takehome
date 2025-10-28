-- Customer type performance
SELECT 
    Customer_Type,
    COUNT(DISTINCT Customer_Number) as customer_count,
    SUM(Revenue) as revenue,
    SUM(profit) as profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(Revenue) / NULLIF(COUNT(DISTINCT Customer_Number), 0) as revenue_per_customer,
    SUM(invoiced_tons) / NULLIF(COUNT(DISTINCT Customer_Number), 0) as tons_per_customer
FROM  aimpoint.default.invoice_lines
GROUP BY Customer_Type
ORDER BY margin_pct DESC