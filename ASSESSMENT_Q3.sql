-- ASSESSMENT_Q3
-- ACCOUNT INACTIVITY ALERT
-- Get savings and investment plans with no deposit activity in over 365 days

SELECT 
    id AS plan_id,                             -- Unique ID of the plan
    owner_id,                                  -- Customer ID
    CASE 
        WHEN is_a_fund = 1 THEN 'Investment'   -- Classify as Investment
        ELSE 'Savings'                         -- Otherwise classify as Savings
    END AS type,
    created_on AS last_transaction_date,       -- Date of last known inflow
    DATEDIFF(CURDATE(), created_on) AS inactivity_days -- Days since last inflow
FROM plans_plan
WHERE 
    amount > 0                                  -- Only consider funded plans
    AND DATEDIFF(CURDATE(), created_on) > 365   -- Last activity was over a year ago
    AND (is_a_fund = 1 OR is_regular_savings = 1); -- Limit to investment or savings plans
