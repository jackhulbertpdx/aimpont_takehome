---
title: Q4 2023 Performance Overview
---



## Key Performance Indicators
```sql q4_metrics
SELECT * FROM q4_summary
```

<BigValue 
    data={q4_metrics} 
    value=total_revenue
    fmt='$#,##0'
    title="Total Revenue"
/>

<BigValue 
    data={q4_metrics} 
    value=total_profit
    fmt='$#,##0'
    title="Total Profit"
/>

<BigValue 
    data={q4_metrics} 
    value=margin_pct
    fmt='#,##0.0"%"'
    title="Gross Margin %"
/>

<BigValue 
    data={q4_metrics} 
    value=total_invoiced_tons
    fmt='#,##0'
    title="Tons Invoiced"
/>

## Q4 Trends
```sql monthly_comparison
SELECT * FROM monthly_trends
ORDER BY month
```

<BarChart
    data={monthly_comparison}
    x=month
    y=revenue
    series=month
    title="Monthly Revenue Comparison"
    yFmt='$#,##0'
/>

<LineChart
    data={monthly_comparison}
    x=month
    y=margin_pct
    title="Margin % Trend"
    yFmt='#0.0"%"'
/>

### Month-over-Month Performance
```sql mom_change
SELECT 
    month,
    revenue,
    profit,
    margin_pct,
    tons,
    LAG(revenue) OVER (ORDER BY month) as prev_revenue,
    LAG(profit) OVER (ORDER BY month) as prev_profit,
    (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100 as revenue_growth_pct,
    (profit - LAG(profit) OVER (ORDER BY month)) / NULLIF(LAG(profit) OVER (ORDER BY month), 0) * 100 as profit_growth_pct
FROM monthly_trends
ORDER BY month
```

<DataTable data={mom_change}>
    <Column id=month title="Month" fmt='mmm yyyy'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=revenue_growth_pct title="Revenue Growth %" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
    <Column id=profit title="Profit" fmt='$#,##0'/>
    <Column id=profit_growth_pct title="Profit Growth %" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"'/>
</DataTable>

## Top-Level Insights
```sql facility_summary
SELECT 
    COUNT(DISTINCT Facility) as facility_count,
    sum(profit)/sum(produced_tons) as profit_per_ton,
    MAX(profit) as best_facility_profit,
    MIN(profit) as worst_facility_profit,
    MAX(profit) - MIN(profit) as diff,
    MAX(profit/produced_tons) as best_facility_profit_per_ton,
    MIN(profit/produced_tons) as worst_facility_profit_per_ton,
    MAX(profit/produced_tons) - MIN(profit/produced_tons) as diff_tons
FROM facility_performance
```
```sql customer_summary
SELECT 
    COUNT(*) as total_customers,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) as unprofitable_customers,
    SUM(CASE WHEN profit < 0 THEN profit ELSE 0 END) as loss_from_unprofitable
FROM customer_profitability
```
```sql inventory_summary
SELECT 
    SUM(inventory_accumulation) as total_inventory_change,
    SUM(inventory_value) as total_inventory_value
FROM production_sales_gap
```
### 🎯 Key Wins

- **Revenue Performance**: Q4 generated **{q4_metrics[0].total_revenue.toLocaleString('en-US', {style: 'currency', currency: 'USD', maximumFractionDigits: 0})}** in total revenue across {q4_metrics[0].unique_customers} customers
- **Margin Stability**: Maintained {q4_metrics[0].margin_pct.toFixed(1)}% gross margin despite market pressures
- **Volume Delivery**: Successfully invoiced {q4_metrics[0].total_invoiced_tons.toLocaleString()} tons to customers



### ⚠️ Areas to Address

- **Unprofitable Customers**: <Value data={customer_summary} column=unprofitable_customers /> customers generating negative margins, representing **<Value data={customer_summary} column=loss_from_unprofitable fmt='$#,##0'/>** in losses  


**Facility Performance Variance**:
 - Profit variance of **<Value data={facility_summary} column=diff fmt='$#,##0' />** between best and worst performing facilities

 - Profit per ton variance of **<Value data={facility_summary} column=diff_tons fmt='$#,##0' />** between best and worst performing facilities




## Quick Facility Comparison
```sql top_facilities
SELECT *, profit/produced_tons as profit_per_ton FROM facility_performance
ORDER BY profit DESC
LIMIT 5
```
<Grid cols=2>

<BarChart
    data={top_facilities}
    x=Facility
    y=profit
    title="Facilities by Profit"
    yFmt='$#,##0'
    labels=true
/>

<BarChart
    data={top_facilities}
    x=Facility
    y=profit_per_ton
    title="Facilities by Profit / Ton"
    yFmt='$#,##0'
    labels=true
/>
</Grid>
