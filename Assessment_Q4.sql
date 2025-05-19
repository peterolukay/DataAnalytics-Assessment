SELECT
  u.id                                 AS customer_id,
  u.name                               AS customer_name,
  -- Tenure in months between date_joined and today
  TIMESTAMPDIFF(
    MONTH,
    u.date_joined,
    CURDATE()
  )                                     AS tenure_months,
  -- Total number of transactions
  COUNT(s.id)                           AS total_transactions,
  -- Average transaction amount
  AVG(s.amount)                        AS avg_tx_amount,
  -- Profit per transaction = 0.1% of avg amount
  ROUND(AVG(s.amount) * 0.001, 2)       AS avg_profit_per_transaction,
  -- CLV = (transactions/tenure_months)*12 * avg_profit_per_transaction
  ROUND(
    (COUNT(s.id)
     / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)
    ) * 12
    * (AVG(s.amount) * 0.001),
  2)                                    AS estimated_clv
FROM
  users_customuser u
  LEFT JOIN savings_savingsaccount s
    ON s.owner_id = u.id
GROUP BY
  u.id,
  u.name,
  u.date_joined
HAVING
  tenure_months > 0                     -- exclude zero-month tenures
ORDER BY
  estimated_clv DESC;
