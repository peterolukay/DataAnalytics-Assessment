This README documents the SQL solutions to the four analytical questions asked in this this assessment, explaining the approach taken for each and highlighting any challenges I encountered and their resolutions.


##Question 1: High-Value Customers with Multiple Products

Task: Identify customers who have at least one funded savings plan and one funded investment plan, then sort them by total savings deposits.

#Approach
- Join users to savings transactions: I started from users_customuser and join to savings_savingsaccount to capture all savings transactions per user.

- Filtered for plan ownership using EXISTS

- One EXISTS clause checked for a funded savings plan (using is_regular_savings = 1 and the actual status_id for funded plans, e.g., 2).

- A second EXISTS checked for a funded investment plan (is_fixed_investment = 1 and the same status_id).

- Aggregated & sortGroup by user, sumed their amount values to compute total savings deposits, and sort in descending order to surface top cross-sell prospects.

##Challenges & Resolutions
- Determining the funded status ID: Initially used a placeholder (X) for the funded plan status_id. We resolved this by querying the lookup table (plans_planstatus) or SELECT DISTINCT status_id to find the actual numeric code (e.g., 2).

- Avoiding double-counting and mismatched joins: Ensured accurate filtering using EXISTS subqueries rather than additional joins, which could multiply rows when a user has multiple transactions.



###Question 2: Transaction Frequency Analysis

Task: Compute each customer’s average number of transactions per month and categorize them into High (≥10), Medium (3–9), or Low (≤2) frequency segments.

Approach
- Monthly counts derived table

- Used DATE_FORMAT(transaction_date, '%Y-%m-01') to normalize each date to the first day of its month.

- Grouped transactions by owner_id and this month key, counting transactions per user per month.

- Average calculation

- Aggregated the monthly counts, applying ROUND(AVG(tx_count), 2) to calculate each user’s average transactions per month with two-decimal precision.

Bucketing & presentation
- Joined back to users_customuser, applied a CASE expression to label each user as 'High', 'Medium', or 'Low' frequency, and ordered by average frequency descending.


##Challenges & Resolutions
- PostgreSQL to MySQL syntax differences: The original use of DATE_TRUNC and ::NUMERIC casts caused syntax errors in MySQL. Solution: Adopted DATE_FORMAT for month grouping and ROUND(...,2) for casting.

- Zero-activity months: Note that months without transactions do not appear in the counts. Depending on the business needs, you may wish to generate rows for zero-count months for a more accurate average.



###Question 3: Account Inactivity Alert

Task: Flag all active plans (savings or investments) with no positive inflow transactions in the last 365 days.

Approach
- Derived recent inflows subquery

- Selected distinct plan_id from savings_savingsaccount where amount > 0 and transaction_date >= CURDATE() - INTERVAL 365 DAY.

- Left join to all active plans

- From plans_plan, filtered for active status 

- Left-join to the recent inflows subquery and retain only plans where the joined plan_id is NULL, indicating no inflows in the past year.

- Planed type labeling & ordering

- Used CASE to distinguish savings vs. investment plans.

- Ordered by owner_id and plan_type for easy review.

##Challenges & Resolutions
- MySQL CTE compatibility: While MySQL 8 supports CTEs, earlier versions do not. I replaced the CTE with a derived table in the LEFT JOIN to ensure compatibility across MySQL versions.

- Date arithmetic syntax: Converted PostgreSQL’s CURRENT_DATE - INTERVAL '365 days' to MySQL’s CURDATE() - INTERVAL 365 DAY.



####Question 4: Customer Lifetime Value (CLV) Estimation

Task: Estimate CLV per customer using tenure (in months), total transaction count, and an assumed profit of 0.1% per transaction amount:

Approach
- Joined and aggregated

- LEFT JOIN users_customuser to savings_savingsaccount.

- Calculated tenure_months via TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()).

- Computed total_transactions with COUNT(s.id), and avg_tx_amount with AVG(s.amount).

- Profit and CLV calculation

- avg_profit_per_transaction = ROUND(AVG(s.amount) * 0.001, 2).

- estimated_clv = ROUND((COUNT(s.id) / NULLIF(tenure_months, 0)) * 12 * (AVG(s.amount) * 0.001), 2).

#Filtering & ordering
- Used HAVING tenure_months > 0 to exclude brand-new users (avoiding division by zero).

- Ordered by estimated_clv descending to surface top-value customers.

##Challenges & Resolutions
- MySQL casting and null safeguards: I switched from PostgreSQL casting syntax to MySQL’s ROUND() and used NULLIF(...,0) to prevent division by zero.
