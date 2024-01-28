
# 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” 
# 	 for each month . This analysis helps to get an idea of low and high-performing months 
#	 and take strategic decisions. The final report contains these columns: 
#	 Month, Year, Gross sales Amount

WITH MonthlySales AS (
    SELECT 
        MONTHNAME(S.DATE) AS Month,
        s.fiscal_year AS YEAR_,
        SUM(g.gross_price * s.sold_quantity) AS Gross_sales_amount
    FROM 
        dim_customer c 
    JOIN 
        fact_sales_monthly s ON c.customer_code = s.customer_code
    JOIN 
        fact_gross_price g ON s.product_code = g.product_code
    WHERE 
        c.customer = "Atliq Exclusive"
    GROUP BY 
        MONTHNAME(s.date), YEAR_
)
SELECT 
    Month,
    YEAR_,
    ROUND(Gross_sales_amount, 2) AS Gross_sales_amount
FROM 
    MonthlySales
ORDER BY 
    YEAR_;