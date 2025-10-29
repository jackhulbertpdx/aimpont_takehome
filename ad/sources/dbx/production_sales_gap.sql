-- Production vs Sales alignment by facility
WITH production_totals AS (
    SELECT 
        ip.Facility,
        COUNT(DISTINCT ip.Production_ID) as total_production_batches,
        SUM(il.total_produced_tons) as total_produced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date BETWEEN '2023-10-01' AND '2023-12-31'
    GROUP BY ip.Facility
),
invoice_totals AS (
    SELECT 
        Facility,
        SUM(invoiced_tons) as total_invoiced_tons,
        COUNT(DISTINCT Invoice_Number) as invoice_count
    FROM aimpoint.default.invoice_lines
    WHERE invoice_date BETWEEN '2023-10-01' AND '2023-12-31'
    GROUP BY Facility
)
SELECT 
    COALESCE(pt.Facility, it.Facility) as Facility,
    COALESCE(pt.total_production_batches, 0) as total_production_batches,
    COALESCE(pt.total_produced_tons, 0) as total_produced_tons,
    COALESCE(it.total_invoiced_tons, 0) as total_invoiced_tons,
    COALESCE(pt.total_produced_tons, 0) - COALESCE(it.total_invoiced_tons, 0) as net_inventory_change,
    (COALESCE(pt.total_produced_tons, 0) - COALESCE(it.total_invoiced_tons, 0)) / NULLIF(COALESCE(pt.total_produced_tons, 0), 0) * 100 as inventory_rate_pct,
    COALESCE(pt.total_produced_tons, 0) / NULLIF(COALESCE(pt.total_production_batches, 0), 0) as avg_batch_size_tons,
    COALESCE(it.invoice_count, 0) as invoice_count
FROM production_totals pt
FULL OUTER JOIN invoice_totals it ON pt.Facility = it.Facility
ORDER BY net_inventory_change DESC