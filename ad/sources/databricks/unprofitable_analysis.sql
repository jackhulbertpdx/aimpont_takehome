-- Identify money-losing segments
SELECT 
    'Customer' as segment_type,
    Customer_Name as segment_name,
    SUM(profit) as total_profit,
    SUM(Revenue) as revenue,
    COUNT(DISTINCT Invoice_Number) as transaction_count
FROM aimpoint.default.invoice_lines
GROUP BY Customer_Name
HAVING SUM(profit) < 0

UNION ALL

SELECT 
    'Product Type' as segment_type,
    Product_Type as segment_name,
    SUM(profit) as total_profit,
    SUM(Revenue) as revenue,
    COUNT(DISTINCT Invoice_Number) as transaction_count
FROM aimpoint.default.invoice_lines
GROUP BY Product_Type
HAVING SUM(profit) < 0

ORDER BY total_profit ASC