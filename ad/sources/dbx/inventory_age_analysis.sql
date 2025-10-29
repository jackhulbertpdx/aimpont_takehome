-- Inventory aging - ALL production batches not yet fully invoiced as of Dec 31
WITH production_batches AS (
    -- Get unique production batches with their details
    SELECT DISTINCT
        ip.Production_ID,
        ip.Facility,
        MIN(il.production_date) as production_date,
        MAX(il.total_produced_tons) as total_produced_tons,
        MAX(il.production_cost) as production_cost,
        MAX(il.cost_per_ton) as cost_per_ton,
        MAX(il.Product_Type) as Product_Type,
        MAX(il.size_shapes) as size_shapes
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = ip.Invoice_Line_Number
    GROUP BY ip.Production_ID, ip.Facility
),
invoiced_production AS (
    SELECT 
        ip.Production_ID,
        MAX(il.invoice_date) as last_invoice_date,
        SUM(il.invoiced_tons) as total_invoiced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-12-31'  -- Only invoices through Dec 31
    GROUP BY ip.Production_ID
)
SELECT 
    pb.Facility,
    pb.Production_ID,
    pb.production_date,
    ip.last_invoice_date,
    DATEDIFF(DAY, pb.production_date, COALESCE(ip.last_invoice_date, DATE '2023-12-31')) as days_since_production,
    pb.total_produced_tons,
    COALESCE(ip.total_invoiced_tons, 0) as invoiced_tons,
    pb.total_produced_tons - COALESCE(ip.total_invoiced_tons, 0) as remaining_inventory_tons,
    (pb.total_produced_tons - COALESCE(ip.total_invoiced_tons, 0)) * pb.cost_per_ton as remaining_inventory_value,
    pb.Product_Type,
    pb.size_shapes,
    CASE 
        WHEN ip.last_invoice_date IS NULL THEN 'Never Invoiced'
        WHEN DATEDIFF(DAY, pb.production_date, DATE '2023-12-31') <= 7 THEN '0-7 days'
        WHEN DATEDIFF(DAY, pb.production_date, DATE '2023-12-31') <= 30 THEN '8-30 days'
        WHEN DATEDIFF(DAY, pb.production_date, DATE '2023-12-31') <= 60 THEN '31-60 days'
        ELSE '60+ days'
    END as age_bucket
FROM production_batches pb
LEFT JOIN invoiced_production ip ON pb.Production_ID = ip.Production_ID
WHERE pb.total_produced_tons - COALESCE(ip.total_invoiced_tons, 0) > 0.01  -- Only batches with remaining inventory
ORDER BY days_since_production DESC