CREATE TABLE cad_condo_prices (
    area_part VARCHAR(50),
    date_quarter VARCHAR(10),
    price_index NUMERIC,
    PRIMARY KEY (area_part, date_quarter)
);

COPY cad_condo_prices(area_part, date_quarter, price_index)
FROM 'D:\GLOCAL_Volunteer\Standardized_Tasks\DAT02_TableauProject_CanadaHousingPriceIndexes\dataset_condominium_price_index - Copy.csv'
DELIMITER ','
CSV HEADER;

-- Add quarter_start_date column with ALTER TABLE and substring
ALTER TABLE cad_condo_prices ADD COLUMN quarter_start_date DATE;

UPDATE cad_condo_prices
SET quarter_start_date = 
    CASE
        WHEN SUBSTRING(date_quarter, 1, 2) = 'Q1' THEN TO_DATE(SUBSTRING(date_quarter, 4, 4) || '-01-01', 'YYYY-MM-DD')
        WHEN SUBSTRING(date_quarter, 1, 2) = 'Q2' THEN TO_DATE(SUBSTRING(date_quarter, 4, 4) || '-04-01', 'YYYY-MM-DD')
        WHEN SUBSTRING(date_quarter, 1, 2) = 'Q3' THEN TO_DATE(SUBSTRING(date_quarter, 4, 4) || '-07-01', 'YYYY-MM-DD')
        WHEN SUBSTRING(date_quarter, 1, 2) = 'Q4' THEN TO_DATE(SUBSTRING(date_quarter, 4, 4) || '-10-01', 'YYYY-MM-DD')
    END;

