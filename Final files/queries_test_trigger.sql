-- query for testing trigger in update/insertion in carts_items
-- and update the total_amount_spend from the table carts 

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

INSERT INTO `carts` (`CART_ID`, `SESSION_ID`, `TOTAL_AMOUNT_SPEND`, `CLOSED_CART`, `HAS_ORDER`) VALUES
('CartTest1','SessionTest1', 0, False, False);

INSERT INTO `cart_items` (`CART_ID`, `ITEM_ID`, `QUANTITY`) VALUES
('CartTest1','ItemTest1',2),
('CartTest1','ItemTest2',1),
('CartTest1','ItemTest3',1);

INSERT INTO `payments` (`PAYMENT_ID`, `CART_ID`, `PAYMENT_TYPE`, `CARD_NUMBER`, `EXPIRATION_DATE`, `CVC`, `APPROVED_PAYMENT`) VALUES
('PaymentTest1', 'CartTest1', 'CREDIT', '23412', '2022-01-01', '123', TRUE);

INSERT INTO `orders` (`ORDER_ID`, `PAYMENT_ID`, `CART_ID`, `DATE_ORDER`) VALUES
('OrderTest1', 'PaymentTest1', 'CartTest1', '2022-01-01');

# Selecting and verifying the test data
# in cart_items
SELECT
	cart_items.cart_id,
    cart_items.item_id,
    cart_items.quantity,
    catalog_items.item_price
FROM cart_items
LEFT JOIN catalog_items 
ON cart_items.item_id = catalog_items.item_id
WHERE cart_id = 'CartTest1';

# verifying the actual value for total_spend_amount
SELECT * FROM carts WHERE cart_id = 'CartTest1';

# updating the quantity of the item choose
UPDATE cart_items
SET quantity = 3
WHERE cart_id = 'CartTest1' AND item_id = 'ItemTest1';

# verifying the modification of the quantity in the item in CartTest1
SELECT
	cart_items.cart_id,
    cart_items.item_id,
    catalog_items.item_price
FROM cart_items
LEFT JOIN catalog_items 
ON cart_items.item_id = catalog_items.item_id
WHERE cart_id = 'CartTest1';

# verifying the action of the trigger
# it automatically updated the total_amount_spend 
# in carts
select * from carts where cart_id = 'CartTest1';


## Test trigger log

# verifying that we don't have records in log
select * from `log`;

# inserting a value in accounts
INSERT INTO `accounts` (`ACCOUNT_ID`, `CREATED_AT`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE_NUMBER`) VALUES
('TestTriggerInsertLog','2024-06-24','Isac','Neto','isac.neto@gmail.com','(91) 8599-9593');

# show the action of the trigger in log
select * from `log`;

# update the value in accounts
UPDATE accounts
SET accounts.last_name = 'TriggerUpdateLastName'
WHERE accounts.account_id = 'TestTriggerInsertLog';

UPDATE accounts
SET accounts.email = 'TriggerUpdateEmail'
WHERE accounts.account_id = 'TestTriggerInsertLog';

UPDATE accounts
SET accounts.phone_number = '(11) 9999-9999'
WHERE accounts.account_id = 'TestTriggerInsertLog';

# show the action of the trigger in log
select * from `log`;

# deleting an account
DELETE 
FROM accounts
WHERE accounts.account_id = 'TestTriggerInsertLog';

# show the action of the trigger in log
select * from `log`;