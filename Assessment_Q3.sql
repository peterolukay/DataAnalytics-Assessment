SELECT
  p.id               AS plan_id,
  p.owner_id         AS customer_id,
  CASE
    WHEN p.is_regular_savings  = 1 THEN 'Savings'
    WHEN p.is_fixed_investment = 1 THEN 'Investment'
    ELSE 'Other'
  END                  AS plan_type,
  p.status_id         AS status
FROM
  plans_plan p
  LEFT JOIN (
    -- all plans that *have* had a positive inflow in the last 365 days
    SELECT DISTINCT
      plan_id
    FROM
      savings_savingsaccount
    WHERE
      amount  > 0
      AND transaction_date >= CURDATE() - INTERVAL 365 DAY
  ) AS recent_inflows
    ON p.id = recent_inflows.plan_id
WHERE
  -- keep only plans *without* any recent inflow
  recent_inflows.plan_id IS NULL
  -- and that are currently active
  AND p.status_id = 2
ORDER BY
  p.owner_id,
  plan_type;
