USE PUBify;

DELIMITER $$

-- ------------------------------------ --
-- GENERAL USAGE PROCEDURES n FUNCTIONS --
-- ------------------------------------ --

DROP FUNCTION IF EXISTS within_range_int $$
CREATE FUNCTION within_range_int(min INT, max INT, value INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(value BETWEEN min AND max, TRUE, FALSE);
END $$

DROP FUNCTION IF EXISTS within_range_decimal $$
CREATE FUNCTION within_range_decimal(min DECIMAL, max DECIMAL, value DECIMAL)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(value BETWEEN min AND max, TRUE, FALSE);
END $$

DROP FUNCTION IF EXISTS within_range_datetime $$
CREATE FUNCTION within_range_datetime(min DATETIME, max DATETIME, value DATETIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(min <= value && (max IS NULL OR max >= value), TRUE, FALSE);
END $$

DROP PROCEDURE IF EXISTS send_exception $$
CREATE PROCEDURE send_exception(errorDescription VARCHAR(255))
BEGIN
    -- return an `unhandeled used-defined exception`
    -- see : https://dev.mysql.com/doc/refman/5.5/en/signal.html
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorDescription;
END $$

-- ------------------------------- --
-- SPECIFIC PROCEDURES n FUNCTIONS --
-- ------------------------------- --

/* DRINK */
DROP PROCEDURE IF EXISTS validate_alcohol_level $$
CREATE PROCEDURE validate_alcohol_level(alcohol_level DECIMAL)
BEGIN
    DECLARE max_alcohol_level INT DEFAULT 100;
    DECLARE min_alcohol_level INT DEFAULT 0;

    IF NOT within_range_decimal(min_alcohol_level, max_alcohol_level, alcohol_level) THEN
        CALL send_exception('Alcohol level can\'t be negative!');
    END IF;
END $$

/* HAPPY HOUR */
DROP PROCEDURE IF EXISTS validate_happy_hour_reduction $$
CREATE PROCEDURE validate_happy_hour_reduction(reduction INT)
BEGIN
    DECLARE max_reduction_percent INT DEFAULT 100;
    DECLARE min_reduction_percent INT DEFAULT 1;

    IF NOT within_range_int(min_reduction_percent, max_reduction_percent, reduction) THEN
        CALL send_exception('The reduction percent must be within 1 and 100');
    END IF;
END $$

DROP PROCEDURE IF EXISTS validate_happy_hour_duration $$
CREATE PROCEDURE validate_happy_hour_duration(duration TIME)
BEGIN
    IF duration < 0 THEN
        CALL send_exception('The duration of a Happy Hour can\'t be negative!');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_happy_hour_not_overlapping $$
CREATE PROCEDURE check_happy_hour_not_overlapping(new_startAt DATETIME, new_duration TIME, old_startAt DATETIME)
BEGIN
    DECLARE nb_overlapping INT;
    SET nb_overlapping = (
        # Try and find any happy hours that overlap w/ the being inserted
        SELECT COUNT(*) FROM HappyHour
        WHERE startAt != old_startAt AND
              (new_startAt BETWEEN startAt AND ADDTIME(startAt, duration) OR
              startAt BETWEEN new_startAt AND ADDTIME(new_startAt, new_duration))
        );

    IF nb_overlapping > 0 THEN
        CALL send_exception('Happy hours can\'t be overlapping');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_product_not_composed $$
CREATE PROCEDURE check_product_not_composed(idProduct INT)
BEGIN
    -- Check that the product has ingredients
    IF (SELECT COUNT(*) FROM Food_Ingredient WHERE idFood = idProduct) > 0 THEN
        CALL send_exception('Composed products can\'t be stocked!');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_quantity_not_zero $$
CREATE PROCEDURE check_quantity_not_zero(quantity INT)
BEGIN
    IF quantity <= 0 THEN
        CALL send_exception('The quantity can\'t be 0 or lower');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_start_sale_before_end_sale $$
CREATE PROCEDURE check_start_sale_before_end_sale(`start` DATETIME, `end` DATETIME)
BEGIN
    IF `start` > `end` THEN
        CALL send_exception('Starting sale date can\'t be greater than the ending date');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_product_available $$
CREATE PROCEDURE check_product_available(`date` DATETIME, idBuyable INT)
BEGIN
    DECLARE start_buyable_sale DATETIME;
    DECLARE end_buyable_sale DATETIME;

    SET start_buyable_sale = (
        SELECT startSaleDate
        FROM Buyable
        WHERE idProduct = idBuyable
    );

    SET end_buyable_sale = (
        SELECT endSaleDate
        FROM Buyable
        WHERE idProduct = idBuyable
    );

    if NOT (within_range_datetime(start_buyable_sale, end_buyable_sale, `date`) AND
           within_range_datetime(start_buyable_sale, end_buyable_sale, `date`)) THEN
        CALL send_exception('Product unavailable');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_drink_available_during_happy_hour $$
CREATE PROCEDURE check_drink_available_during_happy_hour(startAtHappyHour DATETIME, idDrink INT)
BEGIN
    DECLARE happy_hour_duration TIME;

    SET happy_hour_duration = (
        SELECT duration
        FROM HappyHour
        WHERE startAt = startAtHappyHour
    );

    CALL check_product_available(startAtHappyHour, idDrink);
    CALL check_product_available(ADDTIME(startAtHappyHour, happy_hour_duration), idDrink);
END $$

DROP PROCEDURE IF EXISTS check_buyable_not_ingredient $$
CREATE PROCEDURE check_buyable_not_ingredient(idBuyable INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM Ingredient
        WHERE Ingredient.idProduct = idBuyable
    ) > 0 THEN
        CALL send_exception('An Ingredient can\'t be a Buyable');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_ingredient_not_buyable $$
CREATE PROCEDURE check_ingredient_not_buyable(idIngredient INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM Buyable
        WHERE Buyable.idProduct = idIngredient
    ) > 0 THEN
        CALL send_exception('A Buyable can\'t be an Ingredient');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_drink_not_food $$
CREATE PROCEDURE check_drink_not_food(idDrink INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM Food
        WHERE Food.idBuyable = idDrink
    ) > 0 THEN
        CALL send_exception('A Food can\'t be a Drink');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_food_not_drink $$
CREATE PROCEDURE check_food_not_drink(idFood INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM Drink
        WHERE Drink.idBuyable = idFood
    ) > 0 THEN
        CALL send_exception('A Drink can\'t be a Food');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_customer_order_not_supply_order $$
CREATE PROCEDURE check_customer_order_not_supply_order(idCustomerOrder INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM SupplyOrder
        WHERE SupplyOrder.idOrder = idCustomerOrder
    ) > 0 THEN
        CALL send_exception('A CustomerOrder can\'t be a SupplyOrder');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_supply_order_not_customer_order $$
CREATE PROCEDURE check_supply_order_not_customer_order(idSupplyOrder INT)
BEGIN
    IF (SELECT COUNT(*)
        FROM CustomerOrder
        WHERE CustomerOrder.idOrder = idSupplyOrder
    ) > 0 THEN
        CALL send_exception('A SupplyOrder can\'t be a CustomerOrder');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_staff_is_active $$
CREATE PROCEDURE check_staff_is_active(idStaff INT)
BEGIN
    IF (SELECT id FROM vActiveStaff WHERE id = idStaff) IS NULL THEN
        CALL send_exception('A deleted staff can\'t perform any actions');
    END IF;
END $$

DROP PROCEDURE IF EXISTS check_not_composed_food $$
CREATE PROCEDURE check_not_composed_food(idFood INT)
BEGIN
    IF (
        SELECT quantity
        FROM Stock
        WHERE idProduct = idFood
    ) > 0 THEN
        CALL send_exception('A stockable Food can\'t have Ingredients');
    END IF;
END $$

DELIMITER ;

