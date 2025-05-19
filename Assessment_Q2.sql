WITH monthly_tx AS (
  SELECT
    owner_id,
    -- truncate to first day of month
    DATE_FORMAT(transaction_date, '%Y-%m-01') AS tx_month,
    COUNT(*) AS tx_count
  FROM
    savings_savingsaccount
  GROUP BY
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m-01')
),

avg_monthly_tx AS (
  SELECT
    owner_id,
    -- use ROUND() and CAST to get two decimals
    ROUND(AVG(tx_count), 2) AS avg_tx_per_month
  FROM
    monthly_tx
  GROUP BY
    owner_id
)

SELECT
  u.id                   AS customer_id,
  u.name                 AS customer_name,
  a.avg_tx_per_month,
  CASE
    WHEN a.avg_tx_per_month >= 10 THEN 'High Frequency'
    WHEN a.avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
  END                     AS frequency_category
FROM
  avg_monthly_tx a
  JOIN users_customuser u ON u.id = a.owner_id
ORDER BY
  a.avg_tx_per_month DESC;
