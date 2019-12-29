USE PUBify;

DELIMITER $$

-- ------------------------------------ --
-- GENERAL USAGE PROCEDURES n FUNCTIONS --
-- ------------------------------------ --

CREATE FUNCTION is_negative_decimal(num DECIMAL)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(num < 0, TRUE, FALSE);
END $$

CREATE FUNCTION is_negative_int(num INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(num < 0, TRUE, FALSE);
END $$

CREATE FUNCTION is_negative_time(`time` TIME)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    RETURN IF(`time` < 0, TRUE, FALSE);
END $$

-- ------------------------------- --
-- SPECIFIC PROCEDURES n FUNCTIONS --
-- ------------------------------- --

/* DRINK */
CREATE PROCEDURE validate_alcohol_level(alcohol_level DECIMAL)
BEGIN
    IF is_negative_decimal(alcohol_level) THEN
        -- return an `unhandeled used-defined exception`
        -- see : https://dev.mysql.com/doc/refman/5.5/en/signal.html
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alcohol level can\'t be negative!';
    END IF;
END $$

/* HAPPY HOUR */
CREATE PROCEDURE validate_happy_hour_reduction(reduction INT)
BEGIN
    DECLARE max_reduction_percent INT;
    DECLARE min_reduction_percent INT;
    SET max_reduction_percent = 100;
    SET min_reduction_percent = 0;

    -- TODO maybe create a function `within_range` ?
    IF reduction <= min_reduction_percent OR reduction > max_reduction_percent THEN
        -- return an `unhandeled used-defined exception`
        -- see : https://dev.mysql.com/doc/refman/5.5/en/signal.html
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The reduction percent must be within 0 and 100';
    END IF;
END $$

CREATE PROCEDURE validate_happy_hour_duration(duration TIME)
BEGIN
    IF is_negative_time(duration) THEN
        -- return an `unhandeled used-defined exception`
        -- see : https://dev.mysql.com/doc/refman/5.5/en/signal.html
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The duration of a Happy Hour can\'t be negative!';
    END IF;
END $$

DELIMITER ;