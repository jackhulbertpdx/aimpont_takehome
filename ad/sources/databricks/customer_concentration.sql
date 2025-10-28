-- Pareto analysis: Top 20% customer contribution
WITH customer_profits AS (
    SELECT 
        Customer_Number,
        Customer_Name,
        SUM(profit) as customer_profit,
        PERCENT_RANK() OVER (ORDER BY SUM(profit) DESC) as profit_percentile
    FROM aimpoint.default.invoice_lines
    GROUP BY Customer_Number, Customer_Name
)
SELECT 
    CASE 
        WHEN profit_percentile <= 0.20 THEN 'Top 20%'
        WHEN profit_percentile <= 0.50 THEN 'Middle 30%'
        ELSE 'Bottom 50%'
    END as customer_segment,
    COUNT(*) as customer_count,
    SUM(customer_profit) as total_profit,
    SUM(customer_profit) / (SELECT SUM(profit) FROM invoice_lines WHERE invoice_date BETWEEN '2023-10-01' AND '2023-11-30') * 100 as pct_of_total_profit
FROM customer_profits
GROUP BY 
    CASE 
        WHEN profit_percentile <= 0.20 THEN 'Top 20%'
        WHEN profit_percentile <= 0.50 THEN 'Middle 30%'
        ELSE 'Bottom 50%'
    END
ORDER BY pct_of_total_profit DESC