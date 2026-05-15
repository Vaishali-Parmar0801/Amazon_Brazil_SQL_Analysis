# 🛒 Amazon Brazil - SQL E-Commerce Analysis

> A comprehensive SQL-based analysis of Amazon Brazil's e-commerce data to identify payment trends, customer behaviour, seasonal patterns, and product insights - with strategic recommendations applicable to Amazon India.

---

## 📊 Project Overview

| Attribute | Detail |
|-----------|--------|
| **Tool** | PostgreSQL |
| **Database** | `amazon_brazil` schema |
| **Tables** | 6 (customers, orders, order_items, product, seller, payments) |
| **Analysis Phases** | 3 (Payment & Product, Segmentation & Revenue, Advanced Analytics) |
| **Total Queries** | 19 SQL queries |
| **Goal** | Extract cross-market learnings for Amazon India's growth strategy |

---

## 📁 Files in This Repository

```
📁 Amazon-Brazil-SQL-Analysis/
│
├── Amazon_Brazil_Raw_Data.csv                # 6 CSV files
├── 🗄️ amazon_analysis_Queries.sql           # All 19 SQL queries
├── 📑 Amazon_Brazil_SQL_Analysis_Report.pdf  # Full analysis report with outputs
└── 📄 README.md                             # This file
```

---

## 🗄️ Database Schema

```
amazon_brazil
│
├── customers        (customer_id, customer_unique_id, zip_code)
├── orders           (order_id, customer_id, status, timestamps)
├── order_items      (order_id, product_id, seller_id, price, freight)
├── product          (product_id, category_name, dimensions, weight)
├── seller           (seller_id, zip_code)
└── payments         (order_id, payment_type, installments, value)
```

---

## 📐 Analysis Structure

### Analysis I - Payment & Product Insights (7 Queries)

| Q | Problem | Key Finding |
|---|---------|-------------|
| Q1 | Avg payment value by type (ascending) | Credit card highest avg (163 BRL); voucher lowest (66 BRL) |
| Q2 | % share of orders by payment type | Credit card dominates at 73.9%; boleto 19% |
| Q3 | Smart products priced 100–500 BRL | 19 products identified; max price 439.99 BRL |
| Q4 | Top 3 months by total sales | May (1,502,589), August (1,428,658), July (1,393,539) |
| Q5 | Categories with price spread >500 BRL | 57 categories; top: utilidades_domesticas (6,732 BRL spread) |
| Q6 | Payment type with least variance (STDDEV) | Voucher (0.00), then boleto (213.58) — most predictable |
| Q7 | Products with null or 1-char category names | 614 products with data quality issues |

---

### Analysis II - Segmentation & Revenue (5 Queries)

| Q | Problem | Key Finding |
|---|---------|-------------|
| Q1 | Order value segments (Low/Medium/High) by payment type | Low (<200) + credit card is dominant (60,548 orders) |
| Q2 | Min, max, avg price per category | PCS category has highest avg price (1,098 BRL) |
| Q3 | Customers with more than 1 order | 3,140 repeat customers; top customers placed 16 orders |
| Q4 | Customer labels: New / Returning / Loyal | Most customers are New (1 order) |
| Q5 | Top 5 revenue categories | fashion_roupa_infanto_juve leads at 570 BRL total |

---

### Analysis III - Advanced Analytics (7 Queries)

| Q | Problem | Key Finding |
|---|---------|-------------|
| Q1 | Seasonal sales totals | Spring leads (4,216,722 BRL), then Summer (4,120,360 BRL) |
| Q2 | Products sold above average quantity | 6,366 products; top product: 527 units sold |
| Q3 | Monthly revenue in 2018 | January highest (950,030 BRL); September lowest (145 BRL) |
| Q4 | Customer segments: Occasional / Regular / Loyal | Occasional: 94,635 \| Regular: 333 \| Loyal: 109 |
| Q5 | Top 20 customers by avg order value | Top customer avg: 6,735 BRL per order |
| Q6 | Running cumulative sales per product per month | Window function with PARTITION BY product_id |
| Q7 | MoM sales growth by payment type (2018) | Boleto Feb: -10% MoM; June: -24% MoM |

---

## 🔑 SQL Concepts Used

```sql
-- Aggregation
AVG(), SUM(), COUNT(), MIN(), MAX(), ROUND(), STDDEV()

-- Filtering
WHERE, HAVING, BETWEEN, ILIKE, IS NULL, LENGTH()

-- Joins
INNER JOIN across 4–5 tables

-- Subqueries
Correlated subqueries for average comparison

-- CTEs (Common Table Expressions)
WITH clause for multi-step logic

-- Window Functions
RANK() OVER(), SUM() OVER(), LAG() OVER()
PARTITION BY, ORDER BY within windows

-- Date Functions
EXTRACT(MONTH/YEAR FROM timestamp), DATE_TRUNC('month', ...)

-- Conditional Logic
CASE WHEN for segmentation and seasonal labelling

-- Temp Tables
CREATE TEMP TABLE for intermediate results
```

---

## 💡 Top Recommendations for Amazon India

1. **Credit Card Partnerships** - 73.9% of orders use credit card. Prioritise EMI options and credit card checkout optimisation.

2. **Festival Sales Alignment** - May, August, and July are peak months. Align Great Indian Festival events with these high-revenue periods.

3. **Tiered Pricing Labels** - 57 categories have >500 BRL price spreads. Introduce Budget / Standard / Premium labels for better navigation.

4. **Customer Retention Programs** - 94,635 customers are Occasional (1-2 orders). First-order discounts and follow-up recommendations can move them to Returning.

5. **Mandatory Category Validation** - 614 products have null or invalid category names, hurting search and recommendations.

6. **Seasonal Marketing Calendar** - Spring and Summer outperform Autumn and Winter. Allocate higher ad budgets to Mar-Aug.

---

## 🛠️ Tools Used

- **PostgreSQL** - Database creation, schema design, all 19 SQL queries
- **pgAdmin / SQL client** - Query execution and output capture

---

## 👩‍💻 Author

**Vaishali Parmar**  
Data Analyst | Next Leap Program  
Milestone 2 - Amazon Brazil SQL Analysis

---

*This project is part of the Next Leap Data Analytics Program*
