---
title: Data Appendix
---
---

## Methodology & Data Scope

### Analysis Period
**Q4 2023**: October 1, 2023 - December 31, 2023

All financial metrics (revenue, cost, profit, margins) are calculated based on invoice dates within this period. Historical production data dating back to 2021 is included in inventory analysis to capture all units on hand.

### Data Sources

**Invoice Lines Table** (`invoice_lines`)
- Primary source for revenue, cost, and margin analysis
- Contains aggregated production data per invoice line
- Fields: Invoice details, customer information, product attributes, financial metrics, production summaries
- Granularity: One row per invoice line item

**Invoice Production Table** (`invoice_production`)  
- Granular production batch tracking
- Links individual production batches (Production_ID) to invoice lines
- Used for inventory calculations and production efficiency analysis
- Enables tracking of partial shipments from production batches over time
- Production dates span from 2021 to present

### Key Calculations

```sql calculation_definitions
SELECT 
    'Gross Margin %' as metric,
    '(Revenue - Cost) / Revenue × 100' as formula,
    'Percentage profitability of each sale' as description
UNION ALL
SELECT 'Profit per Ton', '(Revenue - Cost) / Tons', 'Dollar profit generated per ton sold'
UNION ALL
SELECT 'Inventory Value', 'Σ(Unsold Tons × Cost per Ton)', 'Working capital tied up in unsold production'
UNION ALL
SELECT 'Inventory Rate %', '(Produced Tons - Invoiced Tons) / Produced Tons × 100', 'Percentage of production not yet sold'
UNION ALL
SELECT 'Days Since Production', 'DATEDIFF(Analysis Date, Production Date)', 'Age of inventory in days'
```

<DataTable data={calculation_definitions}>
    <Column id=metric title="Metric"/>
    <Column id=formula title="Formula"/>
    <Column id=description title="Description"/>
</DataTable>

### Inventory Methodology

**Inventory on hand** is calculated as:

1. Identify all unique production batches from `invoice_production` (back to 2021)
2. Sum total tons invoiced per batch through the measurement date
3. Calculate remaining inventory = Total Produced - Total Invoiced
4. Value remaining inventory at original production cost


### Dimensional Analysis

**Customer Profitability**: Aggregated at customer level across all facilities and products. Multi-facility customers are analyzed both in aggregate and by facility.

**Product Profitability**: Aggregated at Product_Type level. Size/shape variations analyzed separately for cost benchmarking.

**Facility Performance**: All metrics calculated at facility level to enable benchmarking and identify operational efficiency gaps.

**Customer Type**: Segmentation based on Customer_Type field for vertical/market analysis.



**Assumptions & Limitations**:
- Cost per ton assumed constant for each production batch
- Customer Type classifications taken as provided in source data
- Multi-facility coordination costs not separately quantified
- Inventory obsolescence risk not explicitly modeled (age used as proxy)
- Production dates for historical batches based on first invoice appearance


# Data Appendix: Self-Service Analysis

**Use the filters and search capabilities below to explore the underlying data for your own insights.**

---

## Customer Analysis

```sql all_customers
SELECT * FROM customer_profitability
ORDER BY profit DESC
```

### All Customers - Full Detail

**Filter and sort to find specific customers or analyze segments**

<DataTable data={all_customers} search=true rows=25>
    <Column id=Customer_Number title="Customer #"/>
    <Column id=Customer_Name title="Customer Name"/>
    <Column id=Customer_Type title="Type"/>
    <Column id=facilities_served title="Facilities" fmt='#,##0'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=tons title="Tons" fmt='#,##0'/>
    <Column id=order_count title="Orders" fmt='#,##0'/>
    <Column id=profit_per_order title="Profit/Order" fmt='$#,##0'/>
</DataTable>

---

## Product Analysis

```sql all_products
SELECT * FROM product_profitability
ORDER BY profit DESC
```

### All Product Types - Full Detail

**Analyze volume, margin, and pricing by product type**

<DataTable data={all_products} search=true rows=25>
    <Column id=Product_Type title="Product Type"/>
    <Column id=volume title="Volume (tons)" fmt='#,##0'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=revenue_per_ton title="$/Ton" fmt='$#,##0'/>
    <Column id=profit_per_ton title="Profit/Ton" fmt='$#,##0'/>
    <Column id=order_count title="Orders" fmt='#,##0'/>
</DataTable>

---

## Facility Analysis

```sql all_facilities
SELECT * FROM facility_performance
ORDER BY profit DESC
```

### All Facilities - Full Detail

**Compare facility performance across all key metrics**

<DataTable data={all_facilities} search=true>
    <Column id=Facility title="Facility"/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=cost title="Cost" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=invoiced_tons title="Invoiced Tons" fmt='#,##0'/>
    <Column id=produced_tons title="Produced Tons" fmt='#,##0'/>
    <Column id=revenue_per_ton title="Rev/Ton" fmt='$#,##0'/>
    <Column id=cost_per_ton title="Cost/Ton" fmt='$#,##0'/>
    <Column id=customer_count title="Customers" fmt='#,##0'/>
    <Column id=product_diversity title="Products" fmt='#,##0'/>
</DataTable>

---

## Size & Shape Cost Analysis

```sql all_size_shapes
SELECT * FROM size_shape_cost_analysis
ORDER BY cost_variance DESC
```

### Size/Shape Cost Variance

**Identify same products with different costs across facilities**

<DataTable data={all_size_shapes} search=true rows=25>
    <Column id=size_shapes title="Size/Shape"/>
    <Column id=Facility title="Facility"/>
    <Column id=order_count title="Orders" fmt='#,##0'/>
    <Column id=volume title="Volume" fmt='#,##0'/>
    <Column id=avg_cost_per_ton title="Avg Cost/Ton" fmt='$#,##0'/>
    <Column id=min_cost_per_ton title="Min Cost/Ton" fmt='$#,##0'/>
    <Column id=max_cost_per_ton title="Max Cost/Ton" fmt='$#,##0'/>
    <Column id=cost_variance title="Cost Variance" fmt='$#,##0' contentType=colorscale scaleColor=red/>
</DataTable>

---

## Multi-Facility Customers

```sql all_multi_facility
SELECT * FROM multi_facility_customers
ORDER BY total_profit ASC
```

### Multi-Facility Customer Detail

**Customers served by more than one facility**

<DataTable data={all_multi_facility} search=true rows=25>
    <Column id=Customer_Number title="Customer #"/>
    <Column id=Customer_Name title="Customer Name"/>
    <Column id=Customer_Type title="Type"/>
    <Column id=facility_count title="# Facilities" fmt='#,##0'/>
    <Column id=facilities title="Facility List"/>
    <Column id=total_revenue title="Revenue" fmt='$#,##0'/>
    <Column id=total_profit title="Profit" fmt='$#,##0' contentType=colorscale/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=total_tons title="Tons" fmt='#,##0'/>
</DataTable>

---

## Inventory Position Detail

```sql all_inventory
SELECT * FROM inventory_position
ORDER BY Facility, inventory_date
```

### Inventory by Facility & Month

**Track inventory levels across all facilities month-by-month**

<DataTable data={all_inventory} search=true>
    <Column id=Facility title="Facility"/>
    <Column id=inventory_date title="Date" fmt='mmm dd, yyyy'/>
    <Column id=uninvoiced_batches title="Batches" fmt='#,##0'/>
    <Column id=inventory_tons title="Tons" fmt='#,##0'/>
    <Column id=inventory_value title="Value" fmt='$#,##0' contentType=colorscale scaleColor=orange/>
</DataTable>

---

## Aged Inventory Detail

```sql all_aged_inventory
SELECT * FROM inventory_age_analysis
ORDER BY days_since_production DESC
```

### All Aged Inventory Items

**Every production batch with remaining inventory as of Dec 31**

<DataTable data={all_aged_inventory} search=true rows=25>
    <Column id=Facility title="Facility"/>
    <Column id=Production_ID title="Production ID"/>
    <Column id=Product_Type title="Product"/>
    <Column id=size_shapes title="Size/Shape"/>
    <Column id=production_date title="Produced" fmt='mmm dd, yyyy'/>
    <Column id=last_invoice_date title="Last Invoice" fmt='mmm dd, yyyy'/>
    <Column id=days_since_production title="Age (days)" fmt='#,##0' contentType=colorscale scaleColor=red/>
    <Column id=remaining_inventory_tons title="Remaining Tons" fmt='#,##0'/>
    <Column id=remaining_inventory_value title="Value" fmt='$#,##0' contentType=colorscale scaleColor=orange/>
    <Column id=age_bucket title="Age Bucket"/>
</DataTable>

---

## Production Batch Detail

```sql all_production_batches
SELECT * FROM production_batch_efficiency
ORDER BY remaining_inventory_value DESC
```

### Production Batch Efficiency Detail

**All production batches with remaining inventory - Q4 sales activity**

<DataTable data={all_production_batches} search=true rows=25>
    <Column id=Facility title="Facility"/>
    <Column id=Production_ID title="Production ID"/>
    <Column id=production_date title="Produced" fmt='mmm dd, yyyy'/>
    <Column id=Product_Type title="Product"/>
    <Column id=size_shapes title="Size/Shape"/>
    <Column id=total_produced_tons title="Produced Tons" fmt='#,##0'/>
    <Column id=production_cost title="Production Cost" fmt='$#,##0'/>
    <Column id=cost_per_ton title="Cost/Ton" fmt='$#,##0'/>
    <Column id=q4_invoices_from_batch title="Q4 Invoices" fmt='#,##0'/>
    <Column id=first_q4_invoice_date title="First Sale" fmt='mmm dd, yyyy'/>
    <Column id=days_to_first_q4_sale title="Days to Sale" fmt='#,##0' contentType=colorscale scaleColor=orange/>
    <Column id=q4_invoiced_from_batch title="Q4 Sold Tons" fmt='#,##0'/>
    <Column id=remaining_inventory_tons title="Remaining Tons" fmt='#,##0'/>
    <Column id=remaining_inventory_value title="Remaining Value" fmt='$#,##0' contentType=colorscale scaleColor=orange/>
</DataTable>

---

## Production-Sales Gap Analysis
```sql all_production_gaps
SELECT * FROM production_sales_gap
ORDER BY net_inventory_change DESC
```

### Facility Production vs Sales

**Q4 production and invoicing alignment by facility**

<DataTable data={all_production_gaps} search=true>
    <Column id=Facility title="Facility"/>
    <Column id=total_production_batches title="Batches" fmt='#,##0'/>
    <Column id=total_produced_tons title="Produced" fmt='#,##0'/>
    <Column id=total_invoiced_tons title="Invoiced" fmt='#,##0'/>
    <Column id=net_inventory_change title="Net Change" fmt='#,##0' contentType=colorscale/>
    <Column id=inventory_rate_pct title="Inventory Rate" fmt='#0.1"%"' contentType=colorscale scaleColor=orange/>
    <Column id=avg_batch_size_tons title="Avg Batch Size" fmt='#,##0'/>
    <Column id=invoice_count title="Invoices" fmt='#,##0'/>
</DataTable>

---

## Customer Type Analysis
```sql all_customer_types
SELECT * FROM customer_type_analysis
ORDER BY margin_pct DESC
```

### Customer Type Segmentation

**Performance metrics by customer type**

<DataTable data={all_customer_types} search=true>
    <Column id=Customer_Type title="Customer Type"/>
    <Column id=customer_count title="Customers" fmt='#,##0'/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=profit title="Profit" fmt='$#,##0' contentType=colorscale/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=revenue_per_customer title="Rev/Customer" fmt='$#,##0'/>
    <Column id=tons_per_customer title="Tons/Customer" fmt='#,##0'/>
</DataTable>

---

## Product Portfolio Matrix
```sql all_portfolio
SELECT * FROM portfolio_matrix
ORDER BY total_profit DESC
```

### Product Portfolio Classification

**Volume vs margin categorization for all products**

<DataTable data={all_portfolio} search=true rows=25>
    <Column id=Product_Type title="Product Type"/>
    <Column id=volume_category title="Volume Category"/>
    <Column id=margin_category title="Margin Category"/>
    <Column id=total_volume title="Total Volume" fmt='#,##0'/>
    <Column id=margin_pct title="Margin %" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
    <Column id=total_profit title="Total Profit" fmt='$#,##0' contentType=colorscale/>
</DataTable>

---

## Unprofitable Segments
```sql all_unprofitable
SELECT * FROM unprofitable_analysis
ORDER BY total_profit ASC
```

### All Unprofitable Segments

**Customers and products with negative margins in Q4**

<DataTable data={all_unprofitable} search=true>
    <Column id=segment_type title="Segment Type"/>
    <Column id=segment_name title="Segment Name"/>
    <Column id=total_profit title="Loss" fmt='$#,##0' contentType=colorscale scaleColor=red/>
    <Column id=revenue title="Revenue" fmt='$#,##0'/>
    <Column id=transaction_count title="Transactions" fmt='#,##0'/>
</DataTable>

---

## Customer Concentration
```sql all_concentration
SELECT * FROM customer_concentration
ORDER BY pct_of_total_profit DESC
```

### Customer Profit Concentration

**Pareto analysis of customer profit contribution**

<DataTable data={all_concentration}>
    <Column id=customer_segment title="Customer Segment"/>
    <Column id=customer_count title="# Customers" fmt='#,##0'/>
    <Column id=total_profit title="Total Profit" fmt='$#,##0'/>
    <Column id=pct_of_total_profit title="% of Total Profit" fmt='#0.1"%"' contentType=colorscale scaleColor=green/>
</DataTable>

---

## Monthly Trends
```sql all_monthly
SELECT * FROM monthly_trends
ORDER BY month
```

