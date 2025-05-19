SELECT
    u.id                   AS customer_id,
    u.name                 AS customer_name,
    SUM(s.amount)          AS total_savings_deposits
FROM
    users_customuser u
    JOIN savings_savingsaccount s
      ON s.owner_id = u.id
WHERE
    EXISTS (
        SELECT 1
        FROM plans_plan p
        WHERE p.owner_id = u.id
          AND p.is_regular_savings = 1
          AND p.status_id = 2  -- 
    )
    AND EXISTS (
        SELECT 1
        FROM plans_plan p
        WHERE p.owner_id = u.id
          AND p.is_fixed_investment = 1
          AND p.status_id = 2  -- same 'funded' status
    )
GROUP BY
    u.id,
    u.name
ORDER BY
    total_savings_deposits DESC;
