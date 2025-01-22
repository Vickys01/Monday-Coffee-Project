select * from city
select * from customers
select * from products
select * from sales


-- Reports & Data Analysis


-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select city_name, Round((cast(population as float) * 0.25)/1000000,2) as coffee_consumers,city_rank from city
order by 2 desc

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT 
	SUM(total) as total_revenue
FROM sales
WHERE 
	EXTRACT(YEAR FROM sale_date)  = 2023
	AND
	EXTRACT(quarter FROM sale_date) = 4



select 
	ci.city_name,
	sum(s.total) as total_revenue
	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id = c.city_id
	where 
	year(s.sale_date) = 2023
	and
	Datepart(quarter,s.sale_date) = 4
	group by ci.city_name
	order by 2 desc


-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?


select 
p.product_name,
count(s.sale_id) as sale_count
from products as p
left join sales as s
on s.product_id = p.product_id
group by p.product_name
order by 2 desc


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city and total sale
-- no of customers in each these city


select
	ci.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_cutomers,
	Round(
		sum(s.total)/
		count(distinct s.customer_id)
		,2) as avg_sale_per_cus

		from sales as s
		join customers as c
		on s.customer_id = c.customer_id
		join city as ci
		on ci.city_id = c.city_id
		group by ci.city_name
		order by 2 desc

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

with city_table as
(
select
      city_name,
	  Round((cast(population as float) * 0.25)/1000000 ,2) as coffee_consumers
	  from city
),
customer_table
AS  
(
select
     ci.city_name,
	 count(distinct c.customer_id) as unique_customer
		from sales as s
		join customers as c
		on s.customer_id = c.customer_id
		join city as ci
		on ci.city_id = c.city_id
		group by ci.city_name
)
select ct.city_name,
       ct.coffee_consumers,
       cit.unique_customer

	   from city_table as ct
	   join customer_table  as cit
	   on ct.city_name = cit.city_name

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select * from 
(
select 
     ci.city_name,
	 p.product_name,
	 DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	  
	from city as ci
	join customers as c
	on ci.city_id = c.city_id
	join sales as s
	on s.customer_id = c.customer_id
	join products as p
	on p.product_id = s.product_id
	group by ci.city_name,p.product_name
) as ti
where rank <=3


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select
      
      ci.city_name,
	  count(distinct c.customer_id) as unique_customer

	  from city as ci
	  left join customers as c
	  on ci.city_id = c.city_id
	  join sales as s
	  on c.customer_id = s.customer_id
	  join products as p
	  on s.product_id = p.product_id

where
       p.product_id between 1 and 14
	   group by ci.city_name
	   order by 2 desc
	
-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with City_table
AS
	(select
		ci.city_name,
		count(distinct s.customer_id) as total_cutomers,
		Round(
			sum(s.total)/
			count(distinct s.customer_id)
			,2) as avg_sale_per_cus

			from sales as s
			join customers as c
			on s.customer_id = c.customer_id
			join city as ci
			on ci.city_id = c.city_id
			group by ci.city_name
			
			),

city_rent AS
(
select 
      city_name,
	  estimated_rent
	  from city
	  )

select 
      cr.city_name,
	  cr.estimated_rent,
	  ct.total_cutomers,
	  ct.avg_sale_per_cus,
	  Round(cr.estimated_rent/ct.total_cutomers,2) as avg_Rent_per_cus
      from city_rent as cr
	  join City_table as ct
	  on cr.city_name = ct.city_name
	  order by 4 desc



-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city


with
monthly_sales
AS
(
	select 
		   ci.city_name,
		   year (s.sale_date) as year_sale,
		   Datepart(month, s.sale_date) as month_sale,
		   sum(s.total) as total_sale



		  from sales as s
				join customers as c
				on s.customer_id = c.customer_id
				join city as ci
				on ci.city_id = c.city_id
				group by ci.city_name,year(s.sale_date), Datepart(month, s.sale_date)
				
),
Growth_ratio
as
(
	Select 
		  city_name,
		  year_sale,
		  month_sale,
		  total_sale as current_sale,
		  lag(total_sale,1) over(partition by city_name order by year_sale,month_sale) as last_month_sale
		  from monthly_sales
		  
)
select 
      city_name,
	  year_sale,
	  month_sale,
	  current_sale,
	  last_month_sale,
	  Round((current_sale - last_month_sale)/last_month_sale * 100 ,2) as growth_ratio
     from growth_ratio
where
      last_month_sale is not null
	  order by 1,2,3

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
-- Conclusion

with City_table
AS
	(select
		ci.city_name,
		SUM(s.total) as total_revenue,
		count(distinct s.customer_id) as total_cutomers,
		Round(
			sum(s.total)/
			count(distinct s.customer_id)
			,2) as avg_sale_per_cus

			from sales as s
			join customers as c
			on s.customer_id = c.customer_id
			join city as ci
			on ci.city_id = c.city_id
			group by ci.city_name
			
			),

city_rent AS
(
select 
      city_name,
	  estimated_rent,
	  round((cast(population as float) * 0.25)/1000000 ,3) as estimated_coffee_consumer_millions
	  from city
	  )

select 
      cr.city_name,
	  cr.estimated_coffee_consumer_millions,
	  ct.total_revenue,
	  cr.estimated_rent as Total_Rent,
	  ct.total_cutomers,
	  ct.avg_sale_per_cus,
	  Round(cr.estimated_rent/ct.total_cutomers,2) as avg_Rent_per_cus
      from city_rent as cr
	  join City_table as ct
	  on cr.city_name = ct.city_name
	  order by 3 desc

/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.

city 4: chennai
     1. Total revenue is very high
	 2. Total cutomers is very high 42
	 3. Average rent per customer is Affordable at 407
