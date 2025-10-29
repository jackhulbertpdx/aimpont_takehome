# Profitability Deep-Dive

## Customer Profitability Distribution
```sql top_customers
SELECT * FROM customer_profitability
ORDER BY profit DESC
LIMIT 10
```
```sql bottom_customers
SELECT * FROM customer_profitability
ORDER BY profit ASC
LIMIT 10
```

<Grid cols=2>
<div>

### Top 10 Customers

These customers represent your best relationships - high profit, strong margins. Priority should be retention, expansion, and using them as templates for ideal customer profiles when prospecting.

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

These customers are destroying value. Review immediately for pricing corrections, service scope reduction, or exit strategies. Taking a phased approach starting with small impact accounts could impact bottom line.

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
    SUM(profit) as total_loss,
    SUM(revenue) as revenue_at_risk
FROM customer_profitability
WHERE profit < 0
```

##

### Recommendation: 
Implement immediate pricing reviews for negative-margin customers. Even converting half of these losses to breakeven would materially improve profitability without sacrificing revenue growth.

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

### Understanding concentration risk is critical for strategic planning. If top customers are driving disproportionate profits, focus on protecting these relationships while building the middle tier. If profit is too diffused, consider pruning low-value accounts 

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

### Customer type segmentation reveals which markets or verticals deliver the best economics. Double down on high-margin segments in sales and marketing efforts, and reassess pricing or cost-to-serve for underperforming segments 

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

### Customers served across multiple facilities may indicate either strategic national accounts or operational inefficiency. Low profitability here suggests coordination issues, duplicate costs, or pricing that doesn't account for complexity 

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

### Key Finding: 
Multi-facility customers average <Value data={multi_facility_summary} column=avg_margin_multi fmt='#0.1"%"'/> margin versus <Value data={single_facility_avg} column=avg_margin_single fmt='#0.1"%"'/> for single-facility customers. 
### Recommendation: 
If multi-facility margins are lower, investigate whether regional pricing strategies need adjustment or if customer should be consolidated to primary facility where possible.

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

Product mix directly drives overall profitability. Sales teams should be incentivized on margin dollars, not just revenue. High-margin products deserve premium positioning and marketing investment 

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

### Product Strategy: 
- High volume + high margin = protect and grow
- High volume + low margin = improve pricing or efficiency
- Low volume + high margin = expand carefully
- Low volume + low margin = consider discontinuation. 

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

Every dollar lost here is a direct opportunity for margin improvement. These customer and product segments require immediate action - whether price increases, cost reduction, or strategic exits. Low-hanging fruit for profitability gains 

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

### Total Opportunity:
 Eliminating losses from unprofitable segments would add <Value data={unprofitable_impact} column=total_losses fmt='$#,##0'/> directly to the bottom line.
 
  ### Action Plan: 
  Prioritize by size of loss - address the biggest offenders first with pricing corrections or service level adjustments. Set 90-day deadline for all segments to reach breakeven or exit.

