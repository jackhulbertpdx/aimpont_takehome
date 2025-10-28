-- Pareto Analysis: Customer Contribution by Profit Segment
WITH customer_profits AS (
    SELECT 
        Customer_Number,
        Customer_Name,
        SUM(profit) AS customer_profit
    FROM aimpoint.default.invoice_lines
    GROUP BY Customer_Number, Customer_Name
),
ordered_customers AS (
    SELECT
        Customer_Number,
        Customer_Name,
        customer_profit,
        customer_profit / SUM(customer_profit) OVER () AS profit_share,
        SUM(customer_profit) OVER (ORDER BY customer_profit DESC) 
            / SUM(customer_profit) OVER () AS cumulative_profit_share
    FROM customer_profits
)
SELECT 
    CASE
        WHEN cumulative_profit_share <= 0.20 THEN 'Top 20%'
        WHEN cumulative_profit_share <= 0.50 THEN 'Next 30%'
        ELSE 'Bottom 50%'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    SUM(customer_profit) AS total_profit,
    ROUND(SUM(customer_profit) / SUM(SUM(customer_profit)) OVER () * 100, 2) AS pct_of_total_profit
FROM ordered_customers
GROUP BY 
    CASE
        WHEN cumulative_profit_share <= 0.20 THEN 'Top 20%'
        WHEN cumulative_profit_share <= 0.50 THEN 'Next 30%'
        ELSE 'Bottom 50%'
    END
ORDER BY 
    total_profit DESC
