<Grid cols=2>
<div>

### Top 10 Customers

<DataTable data={top_customers}>
    <Column id=Customer_Name title="Customer"/>
    <Column id=Customer_Type title="Type"/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale scaleColor=green/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
</DataTable>

</div>
<div>

### Bottom 10 Customers

<DataTable data={bottom_customers}>
    <Column id=Customer_Name title="Customer"/>
    <Column id=Customer_Type title="Type"/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale scaleColor=red/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
</DataTable>

</div>
</Grid>

```sql unprofitable_total
SELECT 
    COUNT(*) as unprofitable_count,
    count(distinct Customer_number) as customers,
    SUM(profit) as total_loss,
    SUM(revenue) as revenue_at_risk
FROM customer_profitability
WHERE profit < 0
```



## Customer Concentration
```sql concentration
SELECT * FROM customer_concentration
ORDER BY pct_of_total_profit DESC
```

<BarChart
    data={concentration}
    x=customer_segment
    y=pct_of_total_profit
    title="Profit Concentration by Customer Segment"
    yFmt='#0.0"%"'
/>

<DataTable data={concentration}>
    <Column id=customer_segment title="Segment"/>
    <Column id=customer_count title="Customers" fmt='#,##0'/>
    <Column id=total_profit title="Total Profit" fmt='$#,##0'/>
    <Column id=pct_of_total_profit title="% of Profit" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
</DataTable>

## Customer Type Performance
```sql type_performance
SELECT * FROM customer_type_analysis
ORDER BY margin_pct DESC
```

<BarChart
    data={type_performance}
    x=Customer_Type
    y=margin_pct
    title="Margin % by Customer Type"
    yFmt='#0.0"%"'
    swapXY=true
/>

<DataTable data={type_performance}>
    <Column id=Customer_Type title="Customer Type"/>
    <Column id=customer_count title="Customers" fmt='#,##0'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0'/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
    <Column id=revenue_per_customer title="Rev/Customer" fmt='$#,##0'/>
</DataTable>

## Multi-Facility Customer Analysis
```sql multi_facility
SELECT * FROM multi_facility_customers
ORDER BY total_profit ASC
LIMIT 15
```

**Customers served by multiple facilities - sorted by least profitable:**

<DataTable data={multi_facility}>
    <Column id=Customer_Name title="Customer"/>
    <Column id=Customer_Type title="Type"/>
    <Column id=facility_count title="Facilities" fmt='#,##0'/>
    <Column id=facilities title="Facility List"/>
    <Column id=total_profit title="Profit" fmt='$#,##0' contentType=colorscale scaleColor=red/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"'/>
    <Column id=total_revenue title="Revenue" fmt='$#,##0'/>
</DataTable>
```sql multi_facility_summary
SELECT 
    AVG(margin_pct) as avg_margin_multi,
    COUNT(*) as multi_facility_customers
FROM multi_facility_customers
```
```sql single_facility_avg
SELECT 
    AVG(margin_pct) as avg_margin_single
FROM customer_profitability
WHERE facilities_served = 1
```

## Product Type Profitability
```sql product_ranking
SELECT * FROM product_profitability
ORDER BY margin_pct DESC
```

<BarChart
    data={product_ranking}
    x=Product_Type
    y=margin_pct
    title="Product Type Margin Ranking"
    yFmt='#0.0"%"'
    swapXY=true
/>

<DataTable data={product_ranking}>
    <Column id=Product_Type title="Product Type"/>
    <Column id=volume title="Volume (tons)" fmt='#,##0'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale scaleColor=green/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
    <Column id=profit_per_ton title="$/Ton" fmt='$#,##0'/>
</DataTable>

## Product Portfolio Matrix
```sql portfolio
SELECT * FROM portfolio_matrix
ORDER BY total_profit DESC
```

<ScatterPlot
    data={portfolio}
    x=total_volume
    y=margin_pct
    series=Product_Type
    size=total_profit
    title="Product Portfolio: Volume vs Margin"
    xFmt='#,##0'
    yFmt='#0.0"%"'
/>

<DataTable data={portfolio}>
    <Column id=Product_Type title="Product"/>
    <Column id=volume_category title="Volume"/>
    <Column id=margin_category title="Margin"/>
    <Column id=total_volume title="Tons" fmt='#,##0'/>
    <Column id=margin_pct title="Margin %" fmt='#0.0"%"' contentType=colorscale scaleColor=green/>
    <Column id=total_profit title="Profit" fmt='$#,##0'/>
</DataTable>

## Unprofitable Segments
```sql unprofitable_segments
SELECT * FROM unprofitable_analysis
ORDER BY total_profit ASC
```

<DataTable data={unprofitable_segments}>
    <Column id=segment_type title="Type"/>
    <Column id=segment_name title="Name"/>
    <Column id=total_profit title="Loss" fmt='$#,##0' contentType=colorscale scaleColor=red/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=transaction_count title="Orders" fmt='#,##0'/>
</DataTable>
```sql unprofitable_impact
SELECT 
    SUM(total_profit) as total_losses
FROM unprofitable_analysis
```
