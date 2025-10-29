-- Inventory flow: Production → Oct Inventory → Nov Inventory → Dec Inventory → Sold
WITH production_batches AS (
    SELECT DISTINCT
        ip.Production_ID,
        ip.Facility,
        MIN(il.production_date) as production_date,
        MAX(il.total_produced_tons) as total_produced_tons,
        MAX(il.Product_Type) as Product_Type
    FROM aimpoint.default.invoice_production ip
    JOIN aimpoint.default.invoice_lines il 
        ON ip.Facility = il.Facility 
        AND ip.Invoice_Number = il.Invoice_Number 
        AND ip.Invoice_Line_Number = il.Invoice_Line_Number
    GROUP BY ip.Production_ID, ip.Facility
),
monthly_status AS (
    SELECT 
        pb.Production_ID,
        pb.Product_Type,
        pb.total_produced_tons,
        -- October status
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM aimpoint.default.invoice_production ip2
                JOIN aimpoint.default.invoice_lines il2 
                    ON ip2.Facility = il2.Facility 
                    AND ip2.Invoice_Number = il2.Invoice_Number 
                    AND ip2.Invoice_Line_Number = il2.Invoice_Line_Number
                WHERE ip2.Production_ID = pb.Production_ID 
                AND il2.invoice_date <= '2023-10-31'
            ) THEN 'Sold by Oct'
            ELSE 'Inventory Oct 31'
        END as oct_status,
        -- November status
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM aimpoint.default.invoice_production ip2
                JOIN aimpoint.default.invoice_lines il2 
                    ON ip2.Facility = il2.Facility 
                    AND ip2.Invoice_Number = il2.Invoice_Number 
                    AND ip2.Invoice_Line_Number = il2.Invoice_Line_Number
                WHERE ip2.Production_ID = pb.Production_ID 
                AND il2.invoice_date <= '2023-11-30'
            ) THEN 'Sold by Nov'
            ELSE 'Inventory Nov 30'
        END as nov_status,
        -- December status
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM aimpoint.default.invoice_production ip2
                JOIN aimpoint.default.invoice_lines il2 
                    ON ip2.Facility = il2.Facility 
                    AND ip2.Invoice_Number = il2.Invoice_Number 
                    AND ip2.Invoice_Line_Number = il2.Invoice_Line_Number
                WHERE ip2.Production_ID = pb.Production_ID 
                AND il2.invoice_date <= '2023-12-31'
            ) THEN 'Sold by Dec'
            ELSE 'Inventory Dec 31'
        END as dec_status
    FROM production_batches pb
)
-- Flow from Production to Oct
SELECT 
    Product_Type as source,
    CONCAT(Product_Type, ' - ', oct_status) as target,
    SUM(total_produced_tons) as value
FROM monthly_status
GROUP BY Product_Type, oct_status

UNION ALL

-- Flow from Oct to Nov (only inventory that wasn't sold in Oct)
SELECT 
    CONCAT(Product_Type, ' - Inventory Oct 31') as source,
    CONCAT(Product_Type, ' - ', nov_status) as target,
    SUM(total_produced_tons) as value
FROM monthly_status
WHERE oct_status = 'Inventory Oct 31'
GROUP BY Product_Type, nov_status

UNION ALL

-- Flow from Nov to Dec (only inventory that wasn't sold by Nov)
SELECT 
    CONCAT(Product_Type, ' - Inventory Nov 30') as source,
    CONCAT(Product_Type, ' - ', dec_status) as target,
    SUM(total_produced_tons) as value
FROM monthly_status
WHERE nov_status = 'Inventory Nov 30'
GROUP BY Product_Type, dec_status

ORDER BY source, target
