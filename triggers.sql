delimter $$
CREATE TRIGGER PAYMENT_UPDATE_HAS_ORDER
AFTER UPDATE
ON PAYMENTS
    FOR EACH ROW
    BEGIN
		IF NEW.APPROVED_PAYMENT = TRUE THEN	UPDATE CARTS;
            SET CARTS.HAS_ORDER = TRUE
		END IF; 
END $$