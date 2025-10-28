-- Customers served by multiple facilities
SELECT 
    Customer_Number,
    Customer_Name,
    Customer_Type,
    COUNT(DISTINCT Facility) as facility_count,
    STRING_AGG(DISTINCT Facility, ', ') as facilities,
    SUM(Revenue) as total_revenue,
    SUM(profit) as total_profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(invoiced_tons) as total_tons
FROM aimpoint.default.invoice_lines
GROUP BY Customer_Number, Customer_Name, Customer_Type
HAVING COUNT(DISTINCT Facility) > 1
ORDER BY facility_count DESC, total_profit ASC  -- Show least profitable multi-facility customers first