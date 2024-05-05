-- Created a view to add columns for deviations of the price index 
DROP VIEW IF EXISTS price_deviations;
CREATE VIEW price_deviations AS
WITH quarterly_deviations AS (
    SELECT
        area_part,
		quarter_start_date,
		LEFT(date_quarter,2) AS quarter,
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
FROM quarterly_deviations;

SELECT *
FROM price_deviations;

-- Calling the view and getting the average quarterly deviation by area and quarter
SELECT area_part AS area, quarter, ROUND(AVG(quarterly_deviation),2) As avg_quarterly_deviation
FROM price_deviations
GROUP BY 1,2
ORDER BY 1,2;

-- Getting the average quarterly deviation by quarter
SELECT quarter, ROUND(AVG(quarterly_deviation),2) As avg_quarterly_deviation_by_quarter
FROM price_deviations
GROUP BY 1
ORDER BY 1;

-- Calling the view and getting the average quarterly deviation by area and year
SELECT area_part AS area, EXTRACT(year FROM quarter_start_date) AS year, ROUND(AVG(quarterly_deviation),2) AS avg_quarterly_deviation_by_year
FROM price_deviations
GROUP BY 1,2
ORDER BY 1,2;

-- Getting the average quarterly deviation by year
SELECT EXTRACT(year FROM quarter_start_date) AS year, ROUND(AVG(quarterly_deviation),2)
FROM price_deviations
GROUP BY 1
ORDER BY 1;
