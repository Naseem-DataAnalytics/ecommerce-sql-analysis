# E-Commerce SQL Analysis Project

An SQL project analyzing customer behavior and sales funnels using the Olist e-commerce dataset. This project demonstrates complex SQL queries to derive business insights.

---

## Analysis & Insights

### Warm-up: Basic Data Checks

This section includes basic queries to verify that the data was loaded correctly and to get a high-level overview of the dataset.

#### Query 1: How many orders are in the database?
```sql
SELECT COUNT(*) FROM orders;
```
**Result Snapshot:**
![Result for Query 1 showing total order count](https://github.com/Naseem-DataAnalytics/ecommerce-sql-analysis/blob/main/query-1-result.png)

#### Query 2: How many customers are in each state?
```sql
SELECT
	customer_state,
	COUNT(customer_unique_id) AS customer_count
FROM
	customers
GROUP BY
	customer_state
ORDER BY
	customer_count DESC;
```
**Result Snapshot:**
![Result for Query 2 showing customer count for each state](https://github.com/Naseem-DataAnalytics/ecommerce-sql-analysis/blob/main/query-2-result.png)

#### Business Question 1: Customer Segmentation

To identify our most valuable customers, I segmented them into 'High-Value', 'Mid-Value', and 'Low-Value' tiers based on their total historical spending. This was achieved by joining customer, order, and payment data, and then using a CTE and a `CASE` statement to apply the labels.

```sql
-- Segment customers based on total spending
WITH customer_spending AS (
  -- First, calculate total spending per customer
  SELECT
    c.customer_unique_id,
    SUM(op.payment_value) AS total_spent
  FROM
    customers c
  JOIN
    orders o ON c.customer_id = o.customer_id
  JOIN
    order_payments op ON o.order_id = op.order_id
  GROUP BY
    c.customer_unique_id
)
-- Now, select from our temporary result and add the segment labels
SELECT
  customer_unique_id,
  total_spent,
  CASE
    WHEN total_spent > 1000 THEN 'High-Value'
    WHEN total_spent > 500 THEN 'Mid-Value'
    ELSE 'Low-Value'
  END AS customer_segment
FROM
  customer_spending
ORDER BY
  total_spent DESC;
```
**Result Snapshot:**
![Table showing customers segmented by total spending](https://github.com/Naseem-DataAnalytics/ecommerce-sql-analysis/blob/main/customer-segmentation-result.png)
