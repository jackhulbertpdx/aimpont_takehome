-- Product type profitability
SELECT 
    Product_Type,
    SUM(invoiced_tons) as volume,
    SUM(Revenue) as revenue,
    SUM(profit) as profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(Revenue) / NULLIF(SUM(invoiced_tons), 0) as revenue_per_ton,
    SUM(profit) / NULLIF(SUM(invoiced_tons), 0) as profit_per_ton,
    COUNT(DISTINCT Invoice_Number) as order_count
FROM aimpoint.default.invoice_lines
WHERE invoice_date BETWEEN '2023-10-01' AND '2023-11-30'
GROUP BY Product_Type
ORDER BY margin_pct DESC