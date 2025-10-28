-- Volume-Margin matrix for portfolio analysis
SELECT 
    Product_Type,
    SUM(invoiced_tons) as total_volume,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(profit) as total_profit,
    CASE 
        WHEN SUM(invoiced_tons) > (SELECT AVG(vol) FROM (SELECT SUM(invoiced_tons) as vol FROM invoice_lines WHERE invoice_date BETWEEN '2023-10-01' AND '2023-11-30' GROUP BY Product_Type) t) 
        THEN 'High Volume' 
        ELSE 'Low Volume' 
    END as volume_category,
    CASE 
        WHEN SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 > (SELECT AVG(margin) FROM (SELECT SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin FROM invoice_lines WHERE invoice_date BETWEEN '2023-10-01' AND '2023-11-30' GROUP BY Product_Type) t) 
        THEN 'High Margin' 
        ELSE 'Low Margin' 
    END as margin_category
FROM aimpoint.default.invoice_lines
GROUP BY Product_Type