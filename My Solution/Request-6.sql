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
