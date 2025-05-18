# DataAnalytics_Assessment

This repository contains SQL solutions for a data analyst technical assessment using a relational database with customer, transaction, and account tables. All queries are written in MySQL and aim to be efficient, accurate, and readable.

## Table of Contents
- [Question 1: High-Value Customers](#question-1-high-value-customers)
- [Question 2: Transaction Frequency Analysis](#question-2-transaction-frequency-analysis)
- [Question 3: Account Inactivity Alert](#question-3-account-inactivity-alert)
- [Question 4: Customer Lifetime Value (CLV)](#question-4-customer-lifetime-value-clv)
- [Challenges Encountered](#challenges-encountered)

---

## Question 1: High-Value Customers

**Deliverable:** Identify customers who have at least one funded savings account and one funded investment plan. Return their total deposits, sorted in descending order.

**Approach:**
- Joined `users_customuser`, `savings_savingsaccount`, and `plans_plan`.
- Filtered only funded savings accounts and investment plans.
- Used aggregate functions and `HAVING` to ensure customers have both products.
- Converted `kobo` to `naira` using division by 100.


---

**Query:**

This query finds customers who have at least one funded savings and one funded investment plan.

```sql
SELECT 
    u.id AS owner_id,
    u.name AS name,
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    SUM(s.confirmed_amount) / 100 AS total_deposits
FROM users_customuser u
JOIN savings_savingsaccount s 
    ON s.owner_id = u.id AND s.confirmed_amount > 0
JOIN plans_plan p 
    ON p.owner_id = u.id AND p.is_a_fund = 1 AND p.amount > 0
GROUP BY u.id, u.name
HAVING COUNT(DISTINCT s.id) >= 1 
   AND COUNT(DISTINCT p.id) >= 1
ORDER BY total_deposits DESC;
 ```

---


## Question 2: Transaction Frequency Analysis

**Deliverable:** Segment customers into frequency categories based on average monthly transactions:
- High Frequency (≥ 10/month)
- Medium Frequency (3–9/month)
- Low Frequency (≤ 2/month)

**Approach:**
- Calculated `total_transactions` and `active_months` per customer.
- Computed average transactions/month.
- Applied `CASE` logic to categorize.
- Aggregated by category.

**Query:**

This query categorizes customers based on their average number of savings transactions per month into High, Medium, or Low frequency groups.

```sql
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM (
    SELECT 
        owner_id,
        COUNT(*) AS total_txns,
        TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1 AS active_months,
        (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) AS avg_txn_per_month,
        CASE
            WHEN (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) >= 10 THEN 'High Frequency'
            WHEN (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM savings_savingsaccount
    GROUP BY owner_id
) AS txn_summary
GROUP BY frequency_category;
```

---

## Question 3: Account Inactivity Alert

**Deliverable:** Flag accounts (savings or investment) with no inflow transactions in the past 365 days.

**Approach:**
- Used `plans_plan` as it includes both savings and investment plans.
- Filtered funded accounts.
- Applied `DATEDIFF` to calculate inactivity duration.
- Returned only those inactive for more than one year.

**Query:**

This query identifies active savings or investment plans with no inflow transactions for over 365 days.

```sql
SELECT 
    id AS plan_id,
    owner_id,
    CASE 
        WHEN is_a_fund = 1 THEN 'Investment'
        ELSE 'Savings'
    END AS type,
    created_on AS last_transaction_date,
    DATEDIFF(CURDATE(), created_on) AS inactivity_days
FROM plans_plan
WHERE 
    amount > 0
    AND DATEDIFF(CURDATE(), created_on) > 365
    AND (is_a_fund = 1 OR is_regular_savings = 1);
```

---

## Question 4: Customer Lifetime Value (CLV)

**Deliverable:** Estimate CLV using transaction volume and tenure:


**Approach:**
- Joined `users_customuser` and `savings_savingsaccount`.
- Calculated tenure using `TIMESTAMPDIFF`.
- Assumed average profit per transaction = 0.1% of average transaction value.
- Grouped by customer and sorted by estimated CLV.

**Query:**
This query estimates CLV based on account tenure, transaction count, and average transaction value.
The formula assumes:

CLV = (transactions / tenure_months) * 12 * avg_profit_per_txn
Where avg_profit_per_txn = 0.1% of average transaction amount

```sql
SELECT 
    u.id AS customer_id,
    u.name AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND((
        (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 *
        ((SUM(s.amount) / COUNT(s.id)) * 0.001)
    ), 2) AS estimated_clv
FROM users_customuser u
JOIN savings_savingsaccount s ON s.owner_id = u.id
WHERE s.amount > 0
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;
```

---

## Challenges Encountered

- **MySQL Version Compatibility:** Certain features like window functions (`OVER`) required rewriting for MySQL 5.7 using subqueries instead.
- **Schema Inference:** Column names like `created_on` vs `created_at`, and `amount` vs `confirmed_amount`, required checking the actual schema.
- **Data Units:** All amount values were in `kobo`, requiring conversion to `naira` for clarity and accuracy.

---



