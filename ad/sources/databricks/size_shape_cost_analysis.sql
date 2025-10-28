-- Cost variance for same size/shapes across facilities
SELECT 
    size_shapes,
    Facility,
    COUNT(*) as order_count,
    SUM(invoiced_tons) as volume,
    AVG(cost_per_ton) as avg_cost_per_ton,
    MIN(cost_per_ton) as min_cost_per_ton,
    MAX(cost_per_ton) as max_cost_per_ton,
    MAX(cost_per_ton) - MIN(cost_per_ton) as cost_variance
FROM aimpoint.default.invoice_lines
WHERE  size_shapes IS NOT NULL
GROUP BY size_shapes, Facility
HAVING COUNT(*) > 5  -- Only include size/shapes with meaningful volume
ORDER BY cost_variance DESC