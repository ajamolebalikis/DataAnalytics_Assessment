-- ASSESSMENT_Q4
-- CUSTOMER LIFETIME VALUE (CLV) 
-- Estimate CLV using transaction volume and tenure
-- Calculate Customer Lifetime Value (CLV) based on transaction frequency and tenure

SELECT 
    u.id AS customer_id,                         -- Customer ID
    u.name AS name,                              -- Customer name
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months, 
    -- Number of months since customer joined

    COUNT(s.id) AS total_transactions,           -- Total number of savings transactions
    ROUND((
        (COUNT(s.id) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 *
        ((SUM(s.amount) / COUNT(s.id)) * 0.001)
    ), 2) AS estimated_clv                       -- Simplified CLV formula (naira)
FROM users_customuser u
JOIN savings_savingsaccount s ON s.owner_id = u.id
WHERE s.amount > 0
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;
