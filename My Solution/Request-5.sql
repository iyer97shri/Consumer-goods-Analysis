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