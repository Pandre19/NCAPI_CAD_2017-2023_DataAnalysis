--adding the new deviation columns to the table
ALTER TABLE cad_condo_prices
ADD COLUMN quarterly_deviation NUMERIC,
ADD COLUMN cum_total_deviation NUMERIC,
ADD COLUMN yearly_deviation NUMERIC,
ADD COLUMN total_deviation NUMERIC;

-- Update the newly added columns with the calculated values from your query
UPDATE cad_condo_prices
SET
    quarterly_deviation = t.quarterly_deviation,
    cum_total_deviation = t.cum_total_deviation,
    yearly_deviation = t.yearly_deviation,
    total_deviation = t.total_deviation
FROM (
    -- Your original query to calculate the values
    WITH quarterly_deviations AS (
        SELECT
            area_part,
            quarter_start_date,
            LEFT(date_quarter, 2) AS quarter,
            DATE_PART('year', quarter_start_date) AS year,
            price_index,
            price_index - LAG(price_index, 1, 100) OVER(PARTITION BY area_part ORDER BY quarter_start_date) AS quarterly_deviation,
            price_index - 100 AS cum_total_deviation
        FROM cad_condo_prices
    )
    SELECT
        *,
        SUM(quarterly_deviation) OVER (
            PARTITION BY area_part, year ORDER BY area_part, quarter_start_date
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS yearly_deviation,
        SUM(quarterly_deviation) OVER (
            PARTITION BY area_part ORDER BY area_part, quarter_start_date
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS total_deviation
    FROM quarterly_deviations
) AS t
WHERE
    cad_condo_prices.area_part = t.area_part
    AND cad_condo_prices.quarter_start_date = t.quarter_start_date;