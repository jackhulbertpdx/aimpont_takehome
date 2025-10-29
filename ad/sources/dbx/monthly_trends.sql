-- October vs November comparison
SELECT 
    DATE_TRUNC('month', invoice_date) as month,
    SUM(Revenue) as revenue,
    SUM(production_cost) as cost,
    SUM(profit) as profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(invoiced_tons) as tons,
    SUM(Revenue) / NULLIF(SUM(invoiced_tons), 0) as revenue_per_ton,
    SUM(production_cost) / NULLIF(SUM(invoiced_tons), 0) as cost_per_ton
FROM aimpoint.default.invoice_lines
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month