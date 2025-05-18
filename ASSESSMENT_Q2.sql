-- ASSESSMENTS__Q2
-- TRANSACTION FREQUENCY ANALYSIS
-- Categorize customers based on how frequently they make transactions per month

-- Outer query aggregates customers into frequency categories
SELECT 
    frequency_category,                        -- Frequency label (High, Medium, Low)
    COUNT(*) AS customer_count,                -- Number of customers in each category
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month -- Average txn per month in this category
FROM (
    -- Inner query: calculates transaction metrics per customer
    SELECT 
        owner_id,                              -- Customer ID
        COUNT(*) AS total_txns,                -- Total number of transactions
        TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1 AS active_months, 
        -- Duration of activity in months (+1 to avoid divide-by-zero)

        (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) AS avg_txn_per_month,
        -- Average transactions per month for each customer

        CASE
            WHEN (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) >= 10 THEN 'High Frequency'
            WHEN (COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1)) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
        -- Assign frequency label based on average txn/month
    FROM savings_savingsaccount
    GROUP BY owner_id                          -- One row per customer
) AS txn_summary
GROUP BY frequency_category;                   -- Final grouping by frequency type