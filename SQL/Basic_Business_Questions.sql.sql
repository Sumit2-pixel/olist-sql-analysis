-- ============================================================
-- Question 1
-- Business Problem:
-- Identify the top 20% customers contributing to total revenue.
-- ============================================================

select
segment,
customer_count,
revenue,
round(
        revenue::numeric /
        sum(revenue) over() * 100
    ,2) as contribution_percent
from
(
select
segment,
count(*) as customer_count,
sum(revenue) as revenue
from
(
select
customer_unique_id,
revenue,
case
    when customer_rank <= top_20_percent then 'Top 20%'
    else 'Remaining 80%'
end as segment
from
(
select
customer_unique_id,
revenue,
row_number() over(order by revenue desc) as customer_rank,
(count(*) over() * 0.20) as top_20_percent
from
(
select
c.customer_unique_id,
sum(oi.price) as revenue
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.customer_unique_id
)t1
)t2
)t3
group by segment
)t4;



-- ============================================================
-- Question 2
-- Business Problem:
-- Identify whether high revenue states generate revenue
-- because of more orders or higher average order value.
-- ============================================================

select
t1.customer_state,
revenue,
orders,
(revenue/orders) as average_order_value
from
(
select
c.customer_state,
sum(oi.price) as revenue,
count(distinct o.order_id) as orders
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.customer_state
)t1
order by revenue desc;



-- ============================================================
-- Question 3
-- Business Problem:
-- Find product categories generating high revenue
-- despite lower sales volume.
-- ============================================================

select
p.product_category_name,
count(*) as sales_volume,
sum(oi.price) as revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_category_name
order by revenue desc,
sales_volume asc;



-- ============================================================
-- Question 4
-- Business Problem:
-- Identify states with the highest average delivery delay.
-- ============================================================

select
t1.customer_state,
avg(delay) as average_delivery_delay
from
(
select
c.customer_state,
(o.order_delivered_customer_date -
o.order_estimated_delivery_date) as delay
from customers c
join orders o
on c.customer_id = o.customer_id
)t1
group by t1.customer_state
order by average_delivery_delay desc;



-- ============================================================
-- Question 5
-- Business Problem:
-- Identify customers who place frequent orders
-- but generate very low revenue.
-- ============================================================

select
c.customer_unique_id,
count(distinct o.order_id) as total_orders,
sum(oi.price) as revenue
from customers c
join orders o
on c.customer_id = o.customer_id
join order_items oi
on o.order_id = oi.order_id
group by c.customer_unique_id
order by total_orders desc,
revenue asc;