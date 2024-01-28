# 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
#    The final output contains these fields, 
#    segment, product_count_2020, product_count_2021, difference.

WITH Product_Count_2020 AS (
SELECT
	dp.segment,COUNT(DISTINCT s.product_code) AS product_count
    FROM
        dim_product dp
    JOIN
        fact_sales_monthly s ON dp.product_code = s.product_code
    WHERE
        s.fiscal_year = 2020
    GROUP BY
        dp.segment
),
Product_Count_2021 AS (
    SELECT
        dp.segment,
        COUNT(DISTINCT s.product_code) AS product_count
    FROM
        dim_product dp
    JOIN
        fact_sales_monthly s ON dp.product_code = s.product_code
    WHERE
        s.fiscal_year = 2021
    GROUP BY
        dp.segment
),
Product_Difference AS (
    SELECT
        PC20.segment,
        PC20.product_count AS product_count_2020,
        PC21.product_count AS product_count_2021,
        PC21.product_count - PC20.product_count AS difference
    FROM
        Product_Count_2020 PC20
    JOIN
        Product_Count_2021 PC21 ON PC20.segment = PC21.segment
)
SELECT
    *
FROM
    Product_Difference
ORDER BY
    difference DESC;