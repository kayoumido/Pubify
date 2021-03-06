-- -----------------------------------------------------
-- Schema PUBify
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS PUBify;
CREATE SCHEMA PUBify DEFAULT CHARSET = utf8mb4;
USE PUBify;

-- -----------------------------------------------------
-- Table Buyable
-- -----------------------------------------------------
CREATE TABLE Buyable (
    idProduct     INT UNSIGNED,
    price         DOUBLE UNSIGNED NOT NULL,
    startSaleDate DATETIME        NOT NULL,
    endSaleDate   DATETIME        NULL,
    CONSTRAINT PK_Buyable PRIMARY KEY (idProduct)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Buyable_CustomerOrder
-- -----------------------------------------------------
CREATE TABLE Buyable_CustomerOrder (
    idBuyable       INT UNSIGNED,
    idCustomerOrder INT UNSIGNED,
    price           DOUBLE UNSIGNED   NOT NULL,
    quantity        SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT PK_Buyable_CustomerOrder PRIMARY KEY (idBuyable, idCustomerOrder)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table CustomerOrder
-- -----------------------------------------------------
CREATE TABLE CustomerOrder (
    idOrder  INT UNSIGNED,
    idWaiter INT UNSIGNED      NOT NULL,
    tableNB  SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT PK_CustomerOrder PRIMARY KEY (idOrder)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Drink
-- -----------------------------------------------------
CREATE TABLE Drink (
    idBuyable    INT UNSIGNED,
    alcoholLevel DECIMAL(3, 1) NOT NULL,
    CONSTRAINT PK_Drink PRIMARY KEY (idBuyable)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Drink_HappyHour
-- -----------------------------------------------------
CREATE TABLE Drink_HappyHour (
    idDrink          INT UNSIGNED NOT NULL,
    startAtHappyHour DATETIME     NOT NULL,
    PRIMARY KEY (startAtHappyHour, idDrink)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Food
-- -----------------------------------------------------
CREATE TABLE Food (
    idBuyable INT UNSIGNED,
    CONSTRAINT PK_Food PRIMARY KEY (idBuyable)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Food_Ingredient
-- -----------------------------------------------------
CREATE TABLE Food_Ingredient (
    idFood       INT UNSIGNED,
    idIngredient INT UNSIGNED,
    quantity     SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT PK_Food_Ingredient PRIMARY KEY (idFood, idIngredient)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table HappyHour
-- -----------------------------------------------------
CREATE TABLE HappyHour (
	startAt          DATETIME,
    idManager        INT UNSIGNED NOT NULL,
    duration         TIME         NOT NULL,
    reductionPercent INT UNSIGNED NOT NULL,
    CONSTRAINT PK_HappyHour PRIMARY KEY (startAt)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Ingredient
-- -----------------------------------------------------
CREATE TABLE Ingredient (
    idProduct INT UNSIGNED,
    CONSTRAINT PK_Ingredient PRIMARY KEY (idProduct)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Manager
-- -----------------------------------------------------
CREATE TABLE Manager (
    idStaff INT UNSIGNED,
    active  BOOLEAN NOT NULL DEFAULT 1,
    CONSTRAINT PK_Manager PRIMARY KEY (idStaff)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Order
-- -----------------------------------------------------
CREATE TABLE `Order` (
    id      INT UNSIGNED AUTO_INCREMENT,
    orderAt DATETIME        NOT NULL,
    tva     DOUBLE UNSIGNED NOT NULL,
    CONSTRAINT PK_Order PRIMARY KEY (id)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Product
-- -----------------------------------------------------
CREATE TABLE Product (
    id             INT UNSIGNED AUTO_INCREMENT,
    name           VARCHAR(100) NOT NULL,
    nameUnitMetric VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_Product PRIMARY KEY (id)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Product_SupplyOrder
-- -----------------------------------------------------
CREATE TABLE Product_SupplyOrder (
    idProduct     INT UNSIGNED,
    idSupplyOrder INT UNSIGNED,
    price         DOUBLE UNSIGNED NOT NULL,
    quantity      INT UNSIGNED    NOT NULL,
    CONSTRAINT PK_Product_SupplyOrder PRIMARY KEY (idProduct, idSupplyOrder)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Staff
-- -----------------------------------------------------
CREATE TABLE Staff (
    id       INT UNSIGNED AUTO_INCREMENT,
    email    VARCHAR(255) NOT NULL,
    name     VARCHAR(45)  NOT NULL,
    lastname VARCHAR(45)  NOT NULL,
    password VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Staff PRIMARY KEY (id),
    CONSTRAINT UC_Staff_email UNIQUE (email)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Stock
-- -----------------------------------------------------
CREATE TABLE Stock (
    id        INT UNSIGNED AUTO_INCREMENT,
    quantity  INT UNSIGNED        NOT NULL,
    idProduct INT UNSIGNED UNIQUE NOT NULL,
    CONSTRAINT PK_Stock PRIMARY KEY (id)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Supplier
-- -----------------------------------------------------
CREATE TABLE Supplier (
    id   INT UNSIGNED AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    CONSTRAINT PK_Supplier PRIMARY KEY (id)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table SupplyOrder
-- -----------------------------------------------------
CREATE TABLE SupplyOrder (
    idOrder    INT UNSIGNED,
    idSupplier INT UNSIGNED NOT NULL,
    idManager  INT UNSIGNED NOT NULL,
    CONSTRAINT PK_SupplyOrder PRIMARY KEY (idOrder)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table UnitMetric
-- -----------------------------------------------------
CREATE TABLE UnitMetric (
    name      VARCHAR(20),
    shortName VARCHAR(3) NOT NULL,
    CONSTRAINT PK_UnitMetric PRIMARY KEY (name)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table Waiter
-- -----------------------------------------------------
CREATE TABLE Waiter (
    idStaff INT UNSIGNED,
    active  BOOLEAN NOT NULL DEFAULT 1,
    CONSTRAINT PK_Waiter PRIMARY KEY (idStaff)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Foreign Keys
-- -----------------------------------------------------
ALTER TABLE Buyable
    ADD CONSTRAINT FK_Buyable_idProduct
        FOREIGN KEY (idProduct)
            REFERENCES Product (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Buyable_CustomerOrder
    ADD INDEX FK_CustomerOrder_Buyable_idOrderCustomerOrder_idx (idCustomerOrder ASC),
    ADD CONSTRAINT FK_Buyable_CustomerOrder_idCustomerOrder
        FOREIGN KEY (idCustomerOrder)
            REFERENCES CustomerOrder (idOrder)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD INDEX FK_Buyable_CustomerOrder_idPBuyable_idx (idBuyable ASC),
    ADD CONSTRAINT FK_Buyable_CustomerOrder_idBuyable
        FOREIGN KEY (idBuyable)
            REFERENCES Buyable (idProduct)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE CustomerOrder
    ADD CONSTRAINT FK_CustomerOrder_idOrder
        FOREIGN KEY (idOrder)
            REFERENCES `Order` (id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD INDEX FK_CustomerOrder_idWaiter_idx (idWaiter ASC),
    ADD CONSTRAINT FK_CustomerOrder_idWaiter
        FOREIGN KEY (idWaiter)
            REFERENCES Waiter (idStaff)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Drink
    ADD CONSTRAINT FK_Drink_idBuyable
        FOREIGN KEY (idBuyable)
            REFERENCES Buyable (idProduct)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;


ALTER TABLE Drink_HappyHour
    ADD INDEX FK_HappyHour_Drink_idDrink_idx (idDrink ASC),
    ADD CONSTRAINT FK_Drink_HappyHour_idBuyableDrink
        FOREIGN KEY (idDrink)
            REFERENCES Drink (idBuyable)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    ADD INDEX FK_HappyHour_Drink_idHappyHour_idx (startAtHappyHour ASC),
    ADD CONSTRAINT FK_Drink_HappyHour_idHappyHour
        FOREIGN KEY (startAtHappyHour)
            REFERENCES HappyHour (startAt)
            ON DELETE CASCADE
            ON UPDATE CASCADE;


ALTER TABLE Food
    ADD CONSTRAINT FK_Food_idBuyable
        FOREIGN KEY (idBuyable)
            REFERENCES Buyable (idProduct)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Food_Ingredient
    ADD INDEX FK_Food_Ingredient_idIngredient_idx (idIngredient ASC),
    ADD CONSTRAINT FK_Food_Ingredient_idFood
        FOREIGN KEY (idFood)
            REFERENCES Food (idBuyable)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    ADD INDEX FK_Food_Ingredient_idFood_idx (idFood ASC),
    ADD CONSTRAINT FK_Food_Ingredient_idIngredient
        FOREIGN KEY (idIngredient)
            REFERENCES Ingredient (idProduct)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE HappyHour
    ADD INDEX FK_Manager_Drink_idManager_idx (idManager ASC),
    ADD CONSTRAINT FK_HappyHour_idManager
        FOREIGN KEY (idManager)
            REFERENCES Manager (idStaff)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Ingredient
    ADD CONSTRAINT FK_Ingredient_idProduct
        FOREIGN KEY (idProduct)
            REFERENCES Product (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Manager
    ADD CONSTRAINT FK_Manager_idStaff
        FOREIGN KEY (idStaff)
            REFERENCES Staff (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Product
    ADD INDEX FK_Product_nameUnitMetrics_idx (nameUnitMetric ASC),
    ADD CONSTRAINT FK_Product_nameUnitMetric
        FOREIGN KEY (nameUnitMetric)
            REFERENCES UnitMetric (name)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Product_SupplyOrder
    ADD INDEX FK_SupplyOrder_Product_idProduct_idx (idProduct ASC),
    ADD CONSTRAINT FK_Product_SupplyOrder_idSupplyOrder
        FOREIGN KEY (idSupplyOrder)
            REFERENCES SupplyOrder (idOrder)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD INDEX FK_SupplyOrder_Product_idOrderSupplyOrder_idx (idSupplyOrder ASC),
    ADD CONSTRAINT FK_Product_SupplyOrder_idProduct
        FOREIGN KEY (idProduct)
            REFERENCES Product (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Stock
    ADD INDEX FK_Stock_idProduct_idx (idProduct ASC),
    ADD CONSTRAINT FK_Stock_idProduct
        FOREIGN KEY (idProduct)
            REFERENCES Product (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE SupplyOrder
    ADD CONSTRAINT FK_SupplyOrder_idOrder
        FOREIGN KEY (idOrder)
            REFERENCES `Order` (id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD INDEX FK_SupplyOrder_idSupplier_idx (idSupplier ASC),
    ADD CONSTRAINT FK_SupplyOrder_idSupplier
        FOREIGN KEY (idSupplier)
            REFERENCES Supplier (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    ADD INDEX FK_SupplyOrder_idManager_idx (idManager ASC),
    ADD CONSTRAINT FK_SupplyOrder_idManager
        FOREIGN KEY (idManager)
            REFERENCES Manager (idStaff)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;

ALTER TABLE Waiter
    ADD CONSTRAINT FK_Waiter_idStaff
        FOREIGN KEY (idStaff)
            REFERENCES Staff (id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE;