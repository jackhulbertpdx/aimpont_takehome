-- Facility profitability ranking
SELECT 
    Facility,
    SUM(Revenue) as revenue,
    SUM(production_cost) as cost,
    SUM(profit) as profit,
    SUM(profit) / NULLIF(SUM(Revenue), 0) * 100 as margin_pct,
    SUM(invoiced_tons) as invoiced_tons,
    SUM(total_produced_tons) as produced_tons,
    SUM(Revenue) / NULLIF(SUM(invoiced_tons), 0) as revenue_per_ton,
    SUM(production_cost) / NULLIF(SUM(total_produced_tons), 0) as cost_per_ton,
    COUNT(DISTINCT Customer_Number) as customer_count,
    COUNT(DISTINCT Product_Type) as product_diversity
FROM aimpoint.default.invoice_lines
GROUP BY Facility
ORDER BY profit DESC