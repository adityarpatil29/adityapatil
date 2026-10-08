-- ============================================================
-- Student Engagement Analysis Queries
-- Author: Aditya R. Patil
-- Context: BA Portfolio - EdTech Domain Analysis
-- Purpose: These queries demonstrate data analysis skills
-- relevant to product decisions in EdTech platforms.
-- Drawn from real patterns observed in 18 years of testing


https://freesql.com/?compressed_code=H4sIAAAAAAAACmWQSw%252BCMBCE7yT8hzmisb6unrStSqKWtGDiqWkqKokKQfT3mwafcNzJN7M7SwioOdv72VQpijI%252FZBUupjxmVxzyEqmxJyfv77byPcVXnMbwPQCIpGA6ZL16mm4XQbIJY02FijuYKpjHUdv8VjWBSIaUf4iizGz6QqRINiz4B0Hwje1h%252FGN0t%252F45g6C5hDTu6mDQUroYDYfv5DpV1x%252FQhSs9l2INtew7XPneQookwmz37u97QjIundIyg3FFJ4RwQZ%252Bd%252BruSaAEAAA%253D%253D&code_language=PL_SQL&db_version=26&code_format=false
-- Calculate profit margin for each product
SELECT 
    PROD_ID,
    AVG(UNIT_COST) AS avg_cost,
    AVG(UNIT_PRICE) AS avg_price,
    ROUND(AVG(UNIT_PRICE - UNIT_COST), 2) AS avg_profit,
    ROUND(((AVG(UNIT_PRICE) - AVG(UNIT_COST)) / AVG(UNIT_COST)) * 100, 2) AS profit_margin_pct
FROM SH.COSTS
GROUP BY PROD_ID
ORDER BY profit_margin_pct DESC;

-- Compare performance across different sales channels
SELECT 
    CHANNEL_ID,
    COUNT(*) AS total_transactions,
    ROUND(AVG(UNIT_PRICE), 2) AS avg_price,
    ROUND(AVG(UNIT_COST), 2) AS avg_cost,
    ROUND(AVG(UNIT_PRICE - UNIT_COST), 2) AS avg_profit
FROM SH.COSTS
GROUP BY CHANNEL_ID
ORDER BY CHANNEL_ID;

-- Find top 10 most profitable products
SELECT 
    PROD_ID,
    ROUND(AVG(UNIT_PRICE - UNIT_COST), 2) AS avg_profit_per_unit,
    COUNT(*) AS number_of_sales,
    ROUND(SUM(UNIT_PRICE - UNIT_COST), 2) AS total_profit
FROM SH.COSTS
GROUP BY PROD_ID
ORDER BY total_profit DESC
