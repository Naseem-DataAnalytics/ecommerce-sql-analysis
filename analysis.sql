-- This file contains the final, polished SQL queries for the E-Commerce Analysis Project.

-- ===================================================================================
-- WARM-UP QUERIES
-- ===================================================================================

-- Query 1: How many orders are in the database?
SELECT COUNT(*) FROM orders;


-- Query 2: How many customers are in each state?
SELECT
	customer_state,
	COUNT(customer_unique_id) AS customer_count
FROM
	customers
GROUP BY
	customer_state
ORDER BY
	customer_count DESC;


-- ===================================================================================
-- BUSINESS ANALYSIS QUERIES
-- ===================================================================================

-- Business Question 1: Segment customers based on total spending
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


-- Business Question 2: Create the final cohort retention chart
WITH cohort_data AS (
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
  -- Next, count the number of unique customers for each cohort and month number
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
