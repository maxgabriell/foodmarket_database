-- 1) trigger to update the total amount spent
-- if the user add more items in the cart

INSERT INTO `merchants` (`MERCHANT_ID`, `MERCHANT_NAME`, `CUISINE_TYPE`) VALUES
('MerchantTest1', 'Merchant Teste', 'Teste');

INSERT INTO `catalog_items` (`ITEM_ID`, `MERCHANT_ID`, `ITEM_NAME`, `ITEM_PRICE`) VALUES
('ItemTest1', 'MerchantTest1', 'Produto 1', 20.50),
('ItemTest2', 'MerchantTest1', 'Produto 2', 11.25),
('ItemTest3', 'MerchantTest1', 'Produto 3', 22.50);

INSERT INTO `accounts` (`ACCOUNT_ID`, `FIRST_NAME`, `LAST_NAME`, `CREATED_AT`, `EMAIL`, `PHONE_NUMBER`) VALUES
('AccountTest1', 'Teste', 'Conta Teste', '2022-12-11 00:00:00', 'teste.conta@gmail.com', '(11) 97278-2212');

INSERT INTO `sessions` (`SESSION_ID`, `ACCOUNT_ID`, `STARTED_AT`, `CLOSED_AT`) VALUES
('SessionTest1', 'AccountTest1', '2022-12-11 00:00:00', NULL);

INSERT INTO `locations` (`LOCATION_ID`, `SESSION_ID`, `STREET_NAME`, `STREET_NUMBER`, `COMPLEMENT`, `POSTAL_CODE`, `CITY`, `STATE`, `COUNTRY`) VALUES
('LocationTest1', 'SessionTest1', 'Rua Teste', '42', 'Apto 23', '90221-22', 'Sao Paulo', 'SP', 'BR');

INSERT INTO `carts` (`CART_ID`, `SESSION_ID`, `CLOSED_CART`, `HAS_ORDER`) VALUES
('CartTest1','SessionTest1', False, False);

INSERT INTO `cart_items` (`CART_ID`, `ITEM_ID`, `QUANTITY`) VALUES
('CartTest1','ItemTest1',2),
('CartTest1','ItemTest2',1),
('CartTest1','ItemTest3',1);

INSERT INTO `payments` (`PAYMENT_ID`, `CART_ID`, `PAYMENT_TYPE`, `CARD_NUMBER`, `EXPIRATION_DATE`, `CVC`, `APPROVED_PAYMENT`) VALUES
('PaymentTest1', 'CartTest1', 'CREDIT', '23412', '2022-01-01', '123', TRUE);

INSERT INTO `orders` (`ORDER_ID`, `PAYMENT_ID`, `CART_ID`, `TOTAL_AMOUNT_SPEND`, `DATE_ORDER`) VALUES
('OrderTest1', 'PaymentTest1', 'CartTest1', 0, '2022-01-01')

DELIMITER $$
CREATE TRIGGER UPDATE_TOTAL_AMOUNT
AFTER UPDATE
ON CART_ITEMS
FOR EACH ROW
BEGIN
	UPDATE `ORDERS`
	SET TOTAL_AMOUNT_SPEND = (
		SELECT SUM(quantity*item_price)
		FROM cart_items
		LEFT JOIN catalog_items ON cart_items.item_id = catalog_items.item_id
		LEFT JOIN carts ON cart_items.cart_item_id = carts.cart_item_id
		WHERE CART_ITEMS.CART_ITEM_ID = NEW.CART_ITEM_ID);
END $$
DELIMITER ;

-- 2) a trigger that inserts a row in a “log” table if the ACCOUNT table is modified
-- with insert, update or delete columns
CREATE TABLE IF NOT EXISTS LOG (
	LOG_ID INTEGER UNSIGNED AUTO_INCREMENT,
    EVENT_DATE DATETIME,
    USER_NAME VARCHAR(250),
    EVENT_TYPE VARCHAR(250),
    TABLE_NM VARCHAR(250),
	COLUMN_NM VARCHAR(250),
    OLD_VALUE VARCHAR(250),
    NEW_VALUE VARCHAR(250),
    PRIMARY KEY (LOG_ID)
);
    
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

select * from accounts;

select * from `log`;

INSERT INTO `accounts` (`ACCOUNT_ID`, `CREATED_AT`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE_NUMBER`) VALUES
('TestTriggerInsertLog','2024-06-24','Isac','Neto','isac.neto@gmail.com','(91) 8599-9593');

select * from `log`;

UPDATE accounts
SET accounts.last_name = 'TriggerUpdateLastName'
WHERE accounts.account_id = 'TestTriggerInsertLog';

select * from `log`;

UPDATE accounts
SET accounts.email = 'TriggerUpdateEmail'
WHERE accounts.account_id = 'TestTriggerInsertLog';

UPDATE accounts
SET accounts.phone_number = '(11) 9999-9999'
WHERE accounts.account_id = 'TestTriggerInsertLog';

DELETE 
FROM accounts
WHERE accounts.account_id = 'TestTriggerInsertLog';

select * from `log`;
select * from `accounts`;