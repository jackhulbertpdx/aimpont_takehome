-- Q4 Executive Summary
SELECT 
    SUM(Revenue) as total_revenue,
    SUM(production_cost) as total_cost,
    SUM(profit) as total_profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(invoiced_tons) as total_invoiced_tons,
    SUM(total_produced_tons) as total_produced_tons,
    COUNT(DISTINCT Invoice_Number) as total_invoices,
    COUNT(DISTINCT Customer_Number) as unique_customers
FROM aimpoint.default.invoice_lines