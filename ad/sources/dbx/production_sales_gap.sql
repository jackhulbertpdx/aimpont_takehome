-- Facilities with production/sales imbalance
SELECT 
    Facility,
    SUM(total_produced_tons) as total_produced,
    SUM(invoiced_tons) as total_invoiced,
    SUM(total_produced_tons - invoiced_tons) as inventory_accumulation,
    (SUM(total_produced_tons - invoiced_tons)) / NULLIF(SUM(total_produced_tons), 0) * 100 as inventory_rate_pct,
    COUNT(DISTINCT production_ids) as production_batch_count,
    SUM(total_produced_tons) / NULLIF(COUNT(DISTINCT production_ids), 0) as avg_batch_size,
    SUM(CASE WHEN total_produced_tons > invoiced_tons 
        THEN (total_produced_tons - invoiced_tons) * cost_per_ton 
        ELSE 0 END) as inventory_value
FROM aimpoint.default.invoice_lines
GROUP BY Facility
ORDER BY inventory_accumulation DESC