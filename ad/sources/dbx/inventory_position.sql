-- Month-end inventory by facility for Q4
WITH all_production AS (
    SELECT DISTINCT
        ip.Facility,
        ip.Production_ID,
        il.production_date,
        il.total_produced_tons,
        il.production_cost,
        il.cost_per_ton
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    -- No date filter - all production ever
),
october_invoiced AS (
    SELECT DISTINCT ip.Production_ID
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-10-31'
),
november_invoiced AS (
    SELECT DISTINCT ip.Production_ID
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-11-30'
),
december_invoiced AS (
    SELECT DISTINCT ip.Production_ID
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    WHERE il.invoice_date <= '2023-12-31'
)
SELECT 
    Facility,
    '2023-10-31' as inventory_date,
    COUNT(DISTINCT CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM october_invoiced) THEN Production_ID END) as uninvoiced_batches,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM october_invoiced) THEN total_produced_tons ELSE 0 END) as inventory_tons,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM october_invoiced) THEN production_cost ELSE 0 END) as inventory_value
FROM all_production
GROUP BY Facility

UNION ALL

SELECT 
    Facility,
    '2023-11-30' as inventory_date,
    COUNT(DISTINCT CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM november_invoiced) THEN Production_ID END) as uninvoiced_batches,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM november_invoiced) THEN total_produced_tons ELSE 0 END) as inventory_tons,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM november_invoiced) THEN production_cost ELSE 0 END) as inventory_value
FROM all_production
GROUP BY Facility

UNION ALL

SELECT 
    Facility,
    '2023-12-31' as inventory_date,
    COUNT(DISTINCT CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM december_invoiced) THEN Production_ID END) as uninvoiced_batches,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM december_invoiced) THEN total_produced_tons ELSE 0 END) as inventory_tons,
    SUM(CASE WHEN Production_ID NOT IN (SELECT Production_ID FROM december_invoiced) THEN production_cost ELSE 0 END) as inventory_value
FROM all_production
GROUP BY Facility

ORDER BY Facility, inventory_date