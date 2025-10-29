-- Production batch efficiency - batches with remaining inventory as of Dec 31
WITH production_batches AS (
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
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    GROUP BY ip.Production_ID, ip.Facility
),
q4_invoiced AS (
    SELECT 
        ip.Production_ID,
        COUNT(DISTINCT il.Invoice_Number) as q4_invoice_count,
        MIN(il.invoice_date) as first_q4_invoice_date,
        MAX(il.invoice_date) as last_q4_invoice_date,
        SUM(il.invoiced_tons) as q4_invoiced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date BETWEEN '2023-10-01' AND '2023-12-31'  -- Q4 invoices
    GROUP BY ip.Production_ID
),
all_invoiced AS (
    -- Total invoiced through Dec 31 (not just Q4)
    SELECT 
        ip.Production_ID,
        SUM(il.invoiced_tons) as total_invoiced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-12-31'
    GROUP BY ip.Production_ID
)
SELECT 
    pb.Facility,
    pb.Production_ID,
    pb.production_date,
    pb.Product_Type,
    pb.size_shapes,
    pb.total_produced_tons,
    pb.production_cost,
    pb.cost_per_ton,
    COALESCE(qi.q4_invoice_count, 0) as q4_invoices_from_batch,
    qi.first_q4_invoice_date,
    qi.last_q4_invoice_date,
    DATEDIFF(DAY, pb.production_date, qi.first_q4_invoice_date) as days_to_first_q4_sale,
    COALESCE(qi.q4_invoiced_tons, 0) as q4_invoiced_from_batch,
    pb.total_produced_tons - COALESCE(ai.total_invoiced_tons, 0) as remaining_inventory_tons,
    (pb.total_produced_tons - COALESCE(ai.total_invoiced_tons, 0)) * pb.cost_per_ton as remaining_inventory_value
FROM production_batches pb
LEFT JOIN q4_invoiced qi ON pb.Production_ID = qi.Production_ID
LEFT JOIN all_invoiced ai ON pb.Production_ID = ai.Production_ID
WHERE pb.total_produced_tons - COALESCE(ai.total_invoiced_tons, 0) > 0.01  -- Only batches with remaining inventory
ORDER BY remaining_inventory_tons DESC