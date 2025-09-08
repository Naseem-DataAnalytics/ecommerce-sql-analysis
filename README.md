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

