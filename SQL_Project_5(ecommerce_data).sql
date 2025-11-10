use college13;
select * from state_location_data;
select * from ecommerce_dataset;


-- 1. Top 10 states by total sales
select customer_state,round(sum(sales_per_order),2) as total_sales
from ecommerce_dataset 
group by customer_state order by total_sales desc limit 10;


-- 2. Average delivery delay by shipping type
select shipping_type, avg(days_for_shipment_real - days_for_shipment_scheduled) as avg_delay
from ecommerce_dataset
group by shipping_type order by avg_delay desc;


-- 3. Most profitable product categories
select category_name, sum(profit_per_order) as total_profit
from ecommerce_dataset
group by category_name order by total_profit desc limit 5;


-- 4. Percentage of successful deliveries per region
select customer_region, 
round(100* sum(case 
               when delivery_status='Delivered' then 1
               else 0
               end) / count(*) , 2) as delivery_success_rate
from ecommerce_dataset
group by customer_region order by delivery_success_rate desc; 


-- 5. Join with state_location_data to map high-sales states with coordinates              
select e.customer_state, s.latitude, s.longitude, sum(e.sales_per_order) as total_sales
from ecommerce_dataset e
inner join state_location_data s
on e.customer_state= s.state
group by e.customer_state, s.latitude, s.longitude
order by total_sales desc limit 10;



-- 6. Top 5 customers by total purchase amount
select customer_id, concat(customer_first_name,' ', customer_last_name) as full_name, sum(sales_per_order) as total_spend
from ecommerce_dataset group by customer_id, full_name
order by total_spend desc limit 10;


-- 7. Month-wise sales trend
select date_format(order_date,'%Y-%m')as month, sum(sales_per_order) as total_sales
from ecommerce_dataset group by month order by month;


-- 8. Discount vs Profit correlation
select round(avg(order_item_discount),2) as avg_discount,
round(avg(profit_per_order),2) as avg_profit from ecommerce_dataset;


-- 9. City with highest average order quantity
select customer_city, round(avg(order_quantity),2) as avg_order_quantity 
from ecommerce_dataset group by customer_city
order by avg_order_quantity desc limit 5;



-- 10. Correlate profit with geographical coordinates
select s.state, s.latitude, s.longitude, sum(e.profit_per_order) as total_profit
from ecommerce_dataset e
inner join state_location_data s
on e.customer_state = s.state
group by s.state, s.latitude, s.longitude
order by total_profit desc;



-- 11. Top 3 Product Categories per State by Total Sales
with category_sales as
(select customer_state, category_name, sum(sales_per_order) as total_sales,
rank() over(partition by customer_state order by sum(sales_per_order) desc) as rnk
from ecommerce_dataset group by customer_state, category_name)
select customer_state, category_name,total_sales
from category_sales where rnk <= 3
order by customer_state, total_sales desc;




-- 12. Customer Retention Analysis (Repeat Customers)
select count(distinct case when order_count > 1 then customer_id end ) as repeat_customers,
count(distinct customer_id) as total_customers,
round(100* count(distinct case when order_count > 1 then customer_id end) / count(distinct customer_id),2) as retention_rate
from 
( select customer_id, count(order_id) as order_count from ecommerce_dataset group by customer_id) t;





-- 13. Average Delivery Delay by Region and Shipping Type
select customer_region, shipping_type,
round(avg(days_for_shipment_real - days_for_shipment_scheduled),2) as avg_delay
from ecommerce_dataset group by customer_region, shipping_type
order by avg_delay desc;



-- 14. State-wise Profitability Rank
select customer_state, sum(profit_per_order) as total_profit, 
rank() over ( order by sum(profit_per_order) desc) as profit_rank
from ecommerce_dataset group by customer_state;



-- 15. Identify Potential Fraud Orders (High Discount + Low Profit)
select order_id, customer_id, order_item_discount, profit_per_order, sales_per_order
from ecommerce_dataset where
order_item_discount > ( select avg(order_item_discount) + 2*stddev(order_item_discount) from ecommerce_dataset)
and profit_per_order < ( select avg(profit_per_order) - stddev(profit_per_order) from ecommerce_dataset)
order by order_item_discount desc;
















































