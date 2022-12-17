-- 1.List all the customer’s names, dates, and products or services used/booked/rented/bought by these customers in a range of two dates.

select
a.first_name,
a.last_name,
o.date_order,
o.order_id,
cti.item_id,
ci.item_name
from accounts a
left join sessions s 
on a.account_id = s.account_id
left join carts c
on s.session_id = c.session_id
left join orders o
on c.cart_id = o.cart_id
left join cart_items cti
on c.cart_id = cti.cart_id
left join catalog_items ci
on cti.item_id = ci.item_id
where o.date_order between '2022-01-01' and '2022-06-01';





-- 2.List the best three customers/products/services/places (you are free to define the criteria for what means “best”)

select 
a.account_id,
a.first_name,
a.last_name,
count(distinct order_id) as total_orders
from accounts a
left join sessions s 
on a.account_id = s.account_id
left join carts c
on s.session_id = c.session_id
left join orders o
on c.cart_id = o.cart_id
group by 1,2,3
order by total_orders desc
limit 3;

-- 3. Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more years, as in the following example. This query only returns one record.

select 
case when date_order between '2020-01-01' and '2023-01-30' then '01/2020 - 01/2023' end as PeriodOfSales,
round(sum(total_amount_spend), 2) as TotalSales,
round(sum(total_amount_spend)/ 24, 2) as MonthlyAverage,
round(sum(total_amount_spend)/ 2, 2) as YearlyAverage 
from carts c
join orders o
on c.cart_id = o.cart_id
where date_order between '2020-01-01' and '2023-01-30'
group by 1
;

-- 4. Get the total sales/bookings/rents/deliveries by geographical location (city/country).
select 
l.city,
l.state,
l.country,
round(sum(total_amount_spend), 2) as total_sales
from locations l 
left join sessions s
on l.session_id = s.session_id
left join carts c
on s.session_id = c.session_id
left join orders o 
on c.cart_id = o.cart_id
group by 1,2,3;


-- 5. List all the locations where products/services were sold, and the product has customer’s ratings
-- (Yes, your ERD must consider that customers can give ratings)

select 
l.street_name,
l.street_number,
l.city,
l.state,
l.country
from locations l 
left join sessions s
on l.session_id = s.session_id
left join carts c
on s.session_id = c.session_id
left join orders o 
on c.cart_id = o.cart_id
left join ratings r
on o.order_id = r.order_id
where r.rating is not null
and o.order_id is not null
limit 50;