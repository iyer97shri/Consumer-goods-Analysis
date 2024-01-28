# 10. Get the Top 3 products in each division that have a high total_sold_quantity 
#	  in the fiscal_year 2021? The final output contains these fields, 
#	  division, product_code


WITH RankedProducts AS (
    SELECT
        dp.division,
        fsm.product_code,
        dp.product,
        SUM(fsm.sold_quantity) AS total_sold_quantity,
        ROW_NUMBER() OVER(PARTITION BY dp.division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
    FROM
        fact_sales_monthly fsm
    JOIN
        dim_product dp ON fsm.product_code = dp.product_code
    WHERE
        fsm.fiscal_year = 2021
    GROUP BY
        dp.division, fsm.product_code, dp.product
)
SELECT
    division,
    product_code,
    product,
    total_sold_quantity,
    rank_order
FROM
    RankedProducts
WHERE
    rank_order <= 3
ORDER BY
    division, rank_order;
