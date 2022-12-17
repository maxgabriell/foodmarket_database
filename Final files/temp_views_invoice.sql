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
select * from INVOICE_1;

CREATE OR REPLACE VIEW INVOCE_2 AS 
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
select * from INVOCE_2