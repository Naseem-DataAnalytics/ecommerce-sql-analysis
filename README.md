# E-Commerce SQL Analysis Project

### Project Summary & Key Findings

This project involved a deep dive into the Olist e-commerce dataset using PostgreSQL. The goal was to answer critical business questions regarding customer behavior, segmentation, and retention. Key findings revealed that the customer base is heavily skewed towards 'Low-Value' segments and that monthly retention drops significantly after the first purchase, highlighting opportunities for targeted engagement strategies.

---
### Tools & Technologies

* **Database:** PostgreSQL
* **IDE:** DBeaver
* **Core SQL Concepts:** CTEs (Common Table Expressions), Advanced Joins, CASE Statements, Aggregate Functions, Date Functions.
* **Key Analyses:** Customer Segmentation, Cohort & Retention Analysis.
* **Visualization:** dbdiagram.io (for ERD)

### Business Recommendations
Based on the SQL analysis of the Olist dataset, the following strategic recommendations can be made to drive customer value and improve long-term retention.

#### 1. Customer Segmentation
Insight: The analysis revealed that the majority of customers fall into the 'Low-Value' segment, with a small group of 'High-Value' customers driving a disproportionate amount of revenue.

#### Recommendation:

Retain High-Value Customers: Implement a loyalty program with exclusive perks (like early access to sales or free shipping) to acknowledge and retain this critical customer segment.

Grow Mid-Value Customers: Target this group with personalized upselling campaigns and product bundles to encourage slightly larger purchases, moving them into the high-value tier.

Activate Low-Value Customers: Focus on encouraging a second purchase from this large segment through a targeted follow-up email campaign that offers a compelling discount on their next order within 30 days.

#### 2. Customer Retention (Cohort Analysis)
Insight: The cohort analysis clearly shows that customer retention drops significantly after the first month. Most new customers make a single purchase and do not return.

#### Recommendation:

Implement a Month-1 Reactivation Campaign: Proactively engage with new customers during their first month with a series of welcome emails that provide value beyond the initial purchase, such as usage tips for their product or personalized recommendations for a second purchase.

Incentivize the Second Purchase: Test offering a time-sensitive voucher (e.g., "15% off your next order in the next 14 days") to motivate new customers to build a habit of shopping with the platform.

Experiment with Loyalty Points: Introduce a simple points system where customers earn rewards on their first purchase that they can apply to their second, encouraging a faster return.

### Database Schema (ERD)

The database is structured around a central `orders` table, which connects to customers, products, sellers, payments, and reviews. This normalized schema ensures data integrity and minimizes redundancy.

![E-Commerce Database ERD](https://raw.githubusercontent.com/Naseem-DataAnalytics/ecommerce-sql-analysis/main/ecommerce-erd.png)
---

## Analysis & Insights

### Initial Data Exploration

This section includes basic queries to verify that the data was loaded correctly and to get a high-level overview of the dataset.

#### Query 1: How many orders are in the database?
```sql
SELECT COUNT(*) FROM orders;
```
**Result Snapshot:**
![Result for Query 1 showing total order count](https://raw.githubusercontent.com/Naseem-DataAnalytics/ecommerce-sql-analysis/main/query-1-result.png)

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
![Result for Query 2 showing customer count for each state](https://raw.githubusercontent.com/Naseem-DataAnalytics/ecommerce-sql-analysis/main/query-2-result.png)

### BUSINESS ANALYSIS QUERIES
#### Business Question 1: Customer Segmentation

To identify our most valuable customers, I segmented them into 'High-Value', 'Mid-Value', and 'Low-Value' tiers based on their total historical spending. This was achieved by joining customer, order, and payment data, and then using a CTE and a `CASE` statement to apply the labels.

```sql
-- Segment customers based on total spending
WITH customer_spending AS (
  -- First, calculating total spending per customer
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
![Table showing customers segmented by total spending](https://raw.githubusercontent.com/Naseem-DataAnalytics/ecommerce-sql-analysis/main/customer-segmentation-result.png)

#### Business Question 2: Cohort Analysis for Customer Retention

This analysis aims to understand customer loyalty and retention over time. I grouped customers into monthly cohorts based on their first purchase date and then tracked their purchasing activity in the subsequent months. This was achieved using multiple CTEs to first establish the cohorts and then to pivot the data into a monthly retention table.

```sql
-- Business Question 2: Create the final cohort retention chart
WITH cohort_data AS (
  -- This is the entire query I just successfully ran
  WITH cohort_items AS (
    SELECT
      c.customer_unique_id,
      DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
  )
  SELECT
    ci.customer_unique_id,
    ci.cohort_month,
    (EXTRACT(YEAR FROM o.order_purchase_timestamp) - EXTRACT(YEAR FROM ci.cohort_month)) * 12 +
    (EXTRACT(MONTH FROM o.order_purchase_timestamp) - EXTRACT(MONTH FROM ci.cohort_month)) AS month_number
  FROM cohort_items ci
  JOIN customers c ON ci.customer_unique_id = c.customer_unique_id
  JOIN orders o ON c.customer_id = o.customer_id
),
cohort_counts AS (
  -- Next, counting the number of unique customers for each cohort and month number
  SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS num_customers
  FROM
    cohort_data
  GROUP BY
    cohort_month,
    month_number
)
-- Finally, pivot the data to create the cohort chart
SELECT
  cohort_month,
  MAX(CASE WHEN month_number = 0 THEN num_customers ELSE NULL END) AS "Month 0",
  MAX(CASE WHEN month_number = 1 THEN num_customers ELSE NULL END) AS "Month 1",
  MAX(CASE WHEN month_number = 2 THEN num_customers ELSE NULL END) AS "Month 2",
  MAX(CASE WHEN month_number = 3 THEN num_customers ELSE NULL END) AS "Month 3",
  MAX(CASE WHEN month_number = 4 THEN num_customers ELSE NULL END) AS "Month 4",
  MAX(CASE WHEN month_number = 5 THEN num_customers ELSE NULL END) AS "Month 5",
  MAX(CASE WHEN month_number = 6 THEN num_customers ELSE NULL END) AS "Month 6",
  MAX(CASE WHEN month_number = 7 THEN num_customers ELSE NULL END) AS "Month 7",
  MAX(CASE WHEN month_number = 8 THEN num_customers ELSE NULL END) AS "Month 8",
  MAX(CASE WHEN month_number = 9 THEN num_customers ELSE NULL END) AS "Month 9",
  MAX(CASE WHEN month_number = 10 THEN num_customers ELSE NULL END) AS "Month 10",
  MAX(CASE WHEN month_number = 11 THEN num_customers ELSE NULL END) AS "Month 11",
  MAX(CASE WHEN month_number = 12 THEN num_customers ELSE NULL END) AS "Month 12"
FROM
  cohort_counts
GROUP BY
  cohort_month
ORDER BY
  cohort_month;
```

**Result Snapshot:**
![Cohort retention chart showing monthly customer activity](https://raw.githubusercontent.com/Naseem-DataAnalytics/ecommerce-sql-analysis/main/cohort-analysis-result.png)

---

---
### Conclusion

This analysis of the Olist dataset demonstrates the power of SQL in transforming raw data into strategic insights. The findings from customer segmentation and cohort analysis highlight the critical importance of early customer engagement. By implementing the recommended strategies, a business can better retain its most valuable customers, improve the lifetime value of new customers, and achieve a higher return on investment from its marketing efforts.

## 📞 Connect with Me

If you have any questions, feedback, or would like to discuss this project further, please feel free to reach out!

* **Email:** naseemmohdcse@gmail.com

