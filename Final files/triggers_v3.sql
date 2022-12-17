-- Trigger to update total_amount_spend on carts
-- when someone update an item in cart_items 
-- or insert an item in cart_items

DELIMITER $$
CREATE FUNCTION `make_sum_total_amount`(`cart_id_value` VARCHAR(64))
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE total_sum FLOAT;
    SELECT SUM(quantity*item_price)
    FROM cart_items 
    LEFT JOIN catalog_items ON cart_items.item_id = catalog_items.item_id
    LEFT JOIN orders ON cart_items.cart_id = orders.cart_id
    WHERE cart_items.cart_id = cart_id_value
    GROUP BY cart_id_value
    INTO total_sum;
    RETURN COALESCE(total_sum, 0);
END; $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER UPDATE_TOTAL_AMOUNT_UPDATE
AFTER UPDATE
ON CART_ITEMS
FOR EACH ROW
BEGIN
    UPDATE CARTS
    SET total_amount_spend = make_sum_total_amount(new.cart_id)
    WHERE cart_id = new.cart_id;
END; $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER UPDATE_TOTAL_AMOUNT_INSERT
AFTER INSERT
ON CART_ITEMS
FOR EACH ROW
BEGIN
    UPDATE CARTS
    SET total_amount_spend = make_sum_total_amount(new.cart_id)
    WHERE cart_id = new.cart_id;
END; $$
DELIMITER ;

-- 2) a trigger that inserts a row in a “log” table if the ACCOUNT table is modified
-- with insert, update or delete columns

DELIMITER $$
CREATE TRIGGER UPDATE_ACCOUNTS
AFTER UPDATE
ON ACCOUNTS
FOR EACH ROW
BEGIN
	INSERT INTO log(EVENT_DATE, USER_NAME, EVENT_TYPE, TABLE_NM, COLUMN_NM, OLD_VALUE, NEW_VALUE) values
    (
		NOW(), 
        USER(), 
        "UPDATE", 
        "ACCOUNTS",
		CASE 
			WHEN OLD.EMAIL <> NEW.EMAIL THEN "EMAIL"
            WHEN OLD.FIRST_NAME <> NEW.FIRST_NAME THEN "FIRST_NAME"
            WHEN OLD.LAST_NAME <> NEW.LAST_NAME THEN "LAST_NAME"
            WHEN OLD.PHONE_NUMBER <> NEW.PHONE_NUMBER THEN "PHONE_NUMBER"
            WHEN OLD.CREATED_AT <> NEW.CREATED_AT THEN "CREATED_AT"
            ELSE NULL
		END,
		CASE 
			WHEN OLD.EMAIL <> NEW.EMAIL THEN OLD.EMAIL
            WHEN OLD.FIRST_NAME <> NEW.FIRST_NAME THEN OLD.FIRST_NAME
            WHEN OLD.LAST_NAME <> NEW.LAST_NAME THEN OLD.LAST_NAME
            WHEN OLD.PHONE_NUMBER <> NEW.PHONE_NUMBER THEN OLD.PHONE_NUMBER
            WHEN OLD.CREATED_AT <> NEW.CREATED_AT THEN OLD.CREATED_AT
            ELSE NULL
		END,
		CASE 
			WHEN OLD.EMAIL <> NEW.EMAIL THEN NEW.EMAIL
            WHEN OLD.FIRST_NAME <> NEW.FIRST_NAME THEN NEW.FIRST_NAME
            WHEN OLD.LAST_NAME <> NEW.LAST_NAME THEN NEW.LAST_NAME
            WHEN OLD.PHONE_NUMBER <> NEW.PHONE_NUMBER THEN NEW.PHONE_NUMBER
            WHEN OLD.CREATED_AT <> NEW.CREATED_AT THEN NEW.CREATED_AT
            ELSE NULL
		END
    );
END $$
DELIMITER ;
   
DELIMITER $$
CREATE TRIGGER INSERT_ACCOUNTS
AFTER INSERT
ON ACCOUNTS
FOR EACH ROW
BEGIN
	INSERT INTO log(EVENT_DATE, USER_NAME, EVENT_TYPE, TABLE_NM, COLUMN_NM, OLD_VALUE, NEW_VALUE) values
    (
		NOW(), 
        USER(), 
        "INSERT",
        "ACCOUNTS",
		"ALL COLUMNS",
		NULL,
        CONCAT(
			"ACCOUNT_ID: ",
            NEW.ACCOUNT_ID
        )
    );
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER DELETE_ACCOUNTS
AFTER DELETE
ON ACCOUNTS
FOR EACH ROW
BEGIN
	INSERT INTO log(EVENT_DATE, USER_NAME, EVENT_TYPE, TABLE_NM, COLUMN_NM, OLD_VALUE, NEW_VALUE) values
    (
		NOW(), 
        USER(), 
        "DELETE",
        "ACCOUNTS",
		"ALL COLUMNS",
		NULL,
        CONCAT(
			"ACCOUNT_ID: ",
            OLD.ACCOUNT_ID
        )
    );
END $$
DELIMITER ;