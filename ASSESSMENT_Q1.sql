-- ASSESSMENT_Q1

-- HIGH VALUE CUSTOMERS WITH MULTIPLE PRODUCTS
-- Use the plans_plan table to identify product types
-- Count funded saving plans per cutomer 
-- Select customers who have both funded savings and investment plans

SELECT 
    u.id AS owner_id,                  -- Customer ID
    u.name AS name,                   -- Customer name
    COUNT(DISTINCT s.id) AS savings_count, -- Count of unique funded savings accounts
    COUNT(DISTINCT p.id) AS investment_count, -- Count of unique funded investment plans
    SUM(s.confirmed_amount) / 100.0 AS total_deposits -- Total confirmed deposit amount (converted from kobo to naira)
FROM 
    users_customuser u
-- Join savings accounts where they are regular savings and funded
JOIN 
    savings_savingsaccount s 
    ON s.owner_id = u.id AND s.confirmed_amount > 0
-- Join investment plans that are actual funds and funded
JOIN 
    plans_plan p 
    ON p.owner_id = u.id AND p.is_a_fund = 1 AND p.amount > 0
GROUP BY 
    u.id, u.name
-- Ensure each customer has at least one of each product
HAVING 
    COUNT(DISTINCT s.id) >= 1 AND COUNT(DISTINCT p.id) >= 1
ORDER BY 
    total_deposits DESC; -- Sort by total deposits in descending order

