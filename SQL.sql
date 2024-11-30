-- find top 10- highest revenue generating products
select top 10 product_id, SUM(sale_price*quantity) as sales-- Get a list of tables and views in the current database
FROM data_orders
group by product_id 
order by sales DESC

-- top 5 highest selling products in each region
with ranked_products AS(SELECT 
        region,
        product_id,
        SUM(quantity) AS total_quantity_sold,
        RANK() OVER (PARTITION BY region ORDER BY SUM(quantity) DESC) AS rank
    FROM  data_orders
    GROUP BY 
        region, product_id)
    
select region,product_id,total_quantity_sold  from ranked_products
where rank<=5
ORDER by region,rank


-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as
(select year(order_date) as order_year, month(order_date)as order_month, sum(sale_price) as sales 
from data_orders 
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023 from cte
group by order_month
order by order_month

-- for each category which month had highest sales 

-- select distinct category from data_orders

--with cte as 
select format(order_date, 'yyyyMM') as order_YEAR_month, category , sum(sale_price) as sales
from data_orders 
group by category,format(order_date, 'yyyyMM')

select order_month, category, sum(sales) as cate_sales
from cte 
group by order_month, category
order by category, cate_sales desc

WITH cte AS (
    SELECT 
        category,
        FORMAT(order_date, 'yyyyMM') AS order_year_month,
        SUM(sale_price) AS sales
    FROM data_orders
    GROUP BY category, FORMAT(order_date, 'yyyyMM')
)

with cte as(
    select category, year(order_date) as year,month(order_date) as month, sum(sale_price) as sales,
    rank() over(partition by category order by sum(sale_price) desc )as rank
    from data_orders
group by category,year(order_date), month(order_date)
)
select category , year, month, sales from cte 
where rank = 1

-- which sub category had highest growth by profit in 2023 compare to 2022

select * from data_orders

with cte as (select sub_category, year(order_date) as year, sum(sale_price) as sales
from data_orders 
group by year(order_date), sub_category )

, cte2 as(
select sub_category,
sum(case when year=2022 then sales else 0 end) as sales_2022,
sum(case when year=2023 then sales else 0 end) as sales_2023 from cte
group by sub_category)

select top 1 *, ((sales_2023 - sales_2022)*100/sales_2022) as growthpercentage from cte2
order by growthpercentage DESC
