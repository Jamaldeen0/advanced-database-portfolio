-- ZAARH Collections: Portfolio 1 schema (8 tables)
-- Run this on a fresh database. Tables are created parents-first so that
-- every foreign key points to a table that already exists.

CREATE DATABASE IF NOT EXISTS zaarh;
USE zaarh;

-- Level 1: tables with no foreign keys
CREATE TABLE Customer (
  customer_id   INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  phone_number  VARCHAR(20),
  address       VARCHAR(200),
  customer_type VARCHAR(20) NOT NULL DEFAULT 'retail'
);

CREATE TABLE Product (
  product_id        INT AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(100) NOT NULL,
  ml_size           INT NOT NULL,
  price             DECIMAL(10,2) NOT NULL,
  quantity_in_stock INT NOT NULL DEFAULT 0
);

CREATE TABLE Ingredient (
  ingredient_id     INT AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(100) NOT NULL,
  cost              DECIMAL(10,2) NOT NULL,
  quantity_in_stock DECIMAL(10,2) NOT NULL
);

-- Level 2: depend on level 1
CREATE TABLE Orders (
  order_id    INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- One product has exactly one recipe (UNIQUE makes it one-to-one)
CREATE TABLE Recipe (
  recipe_id  INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL UNIQUE,
  name       VARCHAR(100) NOT NULL,
  FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Level 3: depend on level 2
-- Junction table: resolves many-to-many between Orders and Product
CREATE TABLE OrderItem (
  order_item_id  INT AUTO_INCREMENT PRIMARY KEY,
  order_id       INT NOT NULL,
  product_id     INT NOT NULL,
  quantity       INT NOT NULL,
  price_at_order DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- One order can have several payments (part-payments)
CREATE TABLE Payment (
  payment_id   INT AUTO_INCREMENT PRIMARY KEY,
  order_id     INT NOT NULL,
  amount       DECIMAL(10,2) NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Junction table: resolves many-to-many between Recipe and Ingredient
CREATE TABLE RecipeIngredient (
  recipe_ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
  recipe_id            INT NOT NULL,
  ingredient_id        INT NOT NULL,
  amount_ml            DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id),
  FOREIGN KEY (ingredient_id) REFERENCES Ingredient(ingredient_id)
);
