# QUERIES

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

-- Here we listed all the names, orders and dates of the costumers and the filtered by the requested range of dates.





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

-- In this query we listed all the customers and their total amount of purchases, then we ordered descendently and limit to only 3 customers, 
-- that way the query will only return the top 3 customers by number of orders.


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
-- Here we created a new column to show what is the period we are refering to, then we summed the data and divided by the period requestd in months.
-- To finalize where filtered by the date and group by the date column wue created.

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
-- Here we calculated the sum of spent money and grouped by the places requested on the query.

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
where r.rating is not null -- filtering only orders with ratings
and o.order_id is not null -- filtering only places with orders
limit 50; -- Our database it too large, that's why we limited in only 50 rows

# TEMP VIEWA FOR INVOICE

CREATE OR REPLACE VIEW INVOICE_1 AS 
WITH order_level as (
	SELECT
		m.merchant_id,
        m.merchant_name,
        o.order_id,
        o.date_order,
        rat.rating,
        AVG(car.total_amount_spend) AS order_value #COULD ALSO BE MAX,MIN SINCE THE VALUE IS DUPLICATED
	FROM 
	merchants m
	JOIN
		catalog_items cat ON m.merchant_id = cat.merchant_id
	JOIN
		cart_items cti ON cat.item_id = cti.item_id
	JOIN
		carts car ON cti.cart_id = car.cart_id
	JOIN
		orders o ON car.cart_id = o.cart_id
	JOIN
		ratings rat ON o.order_id = rat.order_id
	GROUP BY
		1,2,3,4,5
)
SELECT 
	merchant_id,
	merchant_name,
    DATE_FORMAT(date_order,"%M-%Y") month,
    COUNT(order_id) AS total_orders,
    SUM(order_value) AS GMV,
    AVG(rating) AS avg_rating
FROM
	order_level
WHERE
	merchant_id = 'e99411a1-ff51-40a4-9f50-3ba7f60f31d5'
GROUP BY
	1,2,3
;

CREATE OR REPLACE VIEW INVOICE_2 AS 
SELECT
	m.merchant_id,
	m.merchant_name,
	cat.item_id,
	cat.item_name,
	SUM(cti.quantity) AS quantity,
	SUM(cti.quantity * cat.item_price) AS total_sales
FROM 
merchants m
JOIN
	catalog_items cat ON m.merchant_id = cat.merchant_id
JOIN
	cart_items cti ON cat.item_id = cti.item_id
JOIN
	carts car ON cti.cart_id = car.cart_id
JOIN
	orders o ON car.cart_id = o.cart_id
WHERE
	m.merchant_id = 'e99411a1-ff51-40a4-9f50-3ba7f60f31d5'
GROUP BY
	1,2,3,4
;

SELECT * FROM INVOICE_1 ;
SELECT * FROM INVOICE_2 ;
