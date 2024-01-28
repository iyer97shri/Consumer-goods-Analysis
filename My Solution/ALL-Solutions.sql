#1. Provide the list of markets in which customer "Atliq Exclusive" 
#   operates its business in the APAC region.


SELECT DISTINCT(market)  
FROM dim_customer 
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

#------------------------------------------------------------------------------------------------------#

#2. What is the percentage of unique product increase in 2021 vs. 2020? 
#   The final output contains these fields, 
#   unique_products_2020 
#	unique_products_2021 
#	percentage_chg


WITH unique_product_count_cte AS(

	SELECT COUNT(DISTINCT CASE 
							WHEN fiscal_year = 2020 THEN product_code 
						  END) AS unique_products_2020,/* count of distinct/unique products sold in 2020 */
		   COUNT(DISTINCT CASE 
							WHEN fiscal_year = 2021 THEN product_code 
						  END) AS unique_products_2021 /* count of distinct/unique products sold in 2021 */
FROM fact_sales_monthly)
SELECT unique_products_2020,
	   unique_products_2020,
	   CONCAT(ROUND(((unique_products_2021-unique_products_2020)*1.0/unique_products_2020)*100,2),'%') AS percentage_chg
FROM unique_product_count_cte;   

#------------------------------------------------------------------------------------------------------#

# 3. Provide a report with all the unique product counts for each segment and sort 
#    them in descending order of product counts. 
#    The final output contains 2 fields, 
#    segment product_count

SELECT segment, count(DISTINCT product_code) AS product_Count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

#------------------------------------------------------------------------------------------------------#

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

#------------------------------------------------------------------------------------------------------#

#5. Get the products that have the highest and lowest manufacturing costs. 
#   The final output should contain these fields, 
#	product_code, product, manufacturing_cost.

SELECT m.product_code, concat(product," (",variant,")") AS product, cost_year,concat('$',manufacturing_cost) as manufac_cost
FROM fact_manufacturing_cost m
JOIN dim_product p ON m.product_code = p.product_code
WHERE manufacturing_cost= 
(SELECT min(manufacturing_cost) FROM fact_manufacturing_cost)
or 
manufacturing_cost = 
(SELECT max(manufacturing_cost) FROM fact_manufacturing_cost) 
ORDER BY manufacturing_cost DESC;

#------------------------------------------------------------------------------------------------------#

#6. Generate a report which contains the top 5 customers who received an 
#	average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
#	The final output contains these fields, 
#	customer_code, customer, average_discount_percentage

SELECT
     f.customer_code,
     c.customer,
     ROUND(AVG(f.pre_invoice_discount_pct) * 100,2) AS Average_discount_percentage
FROM 
	fact_pre_invoice_deductions f 
JOIN
     dim_customer c ON f.customer_code=c.customer_code
WHERE 
	fiscal_year =2021
AND 
	c.market='India'
GROUP BY 
	f.customer_code,c.customer
Order By 
	Average_discount_percentage DESC
LIMIT 5;

#------------------------------------------------------------------------------------------------------#

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
    
#------------------------------------------------------------------------------------------------------#

# 8. In which quarter of 2020, got the maximum total_sold_quantity? 
#	 The final output contains these fields sorted by the total_sold_quantity, 
#    Quarter, total_sold_quantity.

SELECT
    CASE
        WHEN MONTH(date) IN (9, 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Q2'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM
    fact_sales_monthly
WHERE
    fiscal_year = 2020
GROUP BY
    Quarter
ORDER BY
    total_sold_quantity DESC;
    
#------------------------------------------------------------------------------------------------------#

# 9. Which channel helped to bring more gross sales in the fiscal year 2021 
#    and the percentage of contribution? The final output contains these fields, 
#	 channel, gross_sales_mln, percentage.

WITH Total_Gross_Sales AS (
      SELECT c.channel,sum(s.sold_quantity * g.gross_price) AS total_sales
  FROM
  fact_sales_monthly s 
  JOIN fact_gross_price g ON s.product_code = g.product_code
  JOIN dim_customer c ON s.customer_code = c.customer_code
  WHERE s.fiscal_year= 2021
  GROUP BY c.channel
  ORDER BY total_sales DESC
)
SELECT 
  channel,
  round(total_sales/1000000,2) AS gross_sales_in_millions,
  round(total_sales/(sum(total_sales) OVER())*100,2) AS percentage 
FROM Total_Gross_Sales;

#------------------------------------------------------------------------------------------------------#

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
