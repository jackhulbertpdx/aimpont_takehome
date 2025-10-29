-- Month-end inventory by facility for Q4
-- Properly handles production batches that may appear on multiple invoice lines
WITH production_batches AS (
    -- Get unique production batches with their total production from invoice_production
    -- We need to deduplicate since same Production_ID can appear on multiple invoices
    SELECT DISTINCT
        ip.Production_ID,
        ip.Facility,
        MIN(il.production_date) as production_date,
        MAX(il.total_produced_tons) as total_produced_tons,  -- Should be same for all, take max to be safe
        MAX(il.production_cost) as production_cost,
        MAX(il.cost_per_ton) as cost_per_ton
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    GROUP BY ip.Production_ID, ip.Facility
),
october_invoiced AS (
    -- Total tons invoiced per production batch through October
    SELECT 
        ip.Production_ID,
        SUM(il.invoiced_tons) as total_invoiced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-10-31'
    GROUP BY ip.Production_ID
),
november_invoiced AS (
    -- Total tons invoiced per production batch through November
    SELECT 
        ip.Production_ID,
        SUM(il.invoiced_tons) as total_invoiced_tons
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-11-30'
    GROUP BY ip.Production_ID
),
december_invoiced AS (
    -- Total tons invoiced per production batch through December
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
-- October 31 inventory
SELECT 
    pb.Facility,
    '2023-10-31' as inventory_date,
    COUNT(DISTINCT pb.Production_ID) as uninvoiced_batches,
    SUM(pb.total_produced_tons - COALESCE(oi.total_invoiced_tons, 0)) as inventory_tons,
    SUM((pb.total_produced_tons - COALESCE(oi.total_invoiced_tons, 0)) * pb.cost_per_ton) as inventory_value
FROM production_batches pb
LEFT JOIN october_invoiced oi ON pb.Production_ID = oi.Production_ID
WHERE pb.total_produced_tons > COALESCE(oi.total_invoiced_tons, 0)  -- Only batches with remaining inventory
GROUP BY pb.Facility

UNION ALL

-- November 30 inventory
SELECT 
    pb.Facility,
    '2023-11-30' as inventory_date,
    COUNT(DISTINCT pb.Production_ID) as uninvoiced_batches,
    SUM(pb.total_produced_tons - COALESCE(ni.total_invoiced_tons, 0)) as inventory_tons,
    SUM((pb.total_produced_tons - COALESCE(ni.total_invoiced_tons, 0)) * pb.cost_per_ton) as inventory_value
FROM production_batches pb
LEFT JOIN november_invoiced ni ON pb.Production_ID = ni.Production_ID
WHERE pb.total_produced_tons > COALESCE(ni.total_invoiced_tons, 0)
GROUP BY pb.Facility

UNION ALL

-- December 31 inventory
SELECT 
    pb.Facility,
    '2023-12-31' as inventory_date,
    COUNT(DISTINCT pb.Production_ID) as uninvoiced_batches,
    SUM(pb.total_produced_tons - COALESCE(di.total_invoiced_tons, 0)) as inventory_tons,
    SUM((pb.total_produced_tons - COALESCE(di.total_invoiced_tons, 0)) * pb.cost_per_ton) as inventory_value
FROM production_batches pb
LEFT JOIN december_invoiced di ON pb.Production_ID = di.Production_ID
WHERE pb.total_produced_tons > COALESCE(di.total_invoiced_tons, 0)
GROUP BY pb.Facility

ORDER BY Facility, inventory_date