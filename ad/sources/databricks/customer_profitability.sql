-- Top and bottom customers by profit
SELECT 
    Customer_Number,
    Customer_Name,
    Customer_Type,
    COUNT(DISTINCT Facility) as facilities_served,
    SUM(Revenue) as revenue,
    SUM(profit) as profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(invoiced_tons) as tons,
    COUNT(DISTINCT Invoice_Number) as order_count,
    SUM(profit) / NULLIF(COUNT(DISTINCT Invoice_Number), 0) as profit_per_order
FROM aimpoint.default.invoice_lines
GROUP BY Customer_Number, Customer_Name, Customer_Type
ORDER BY profit DESC