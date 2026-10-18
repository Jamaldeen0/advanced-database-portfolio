USE zaarh;

-- Query 1: products priced above 7000 
SELECT name, price
FROM Product
WHERE price > 7000;

-- Query 2: every payment with the customer's name 
SELECT c.name AS customer, pay.amount, pay.payment_date
FROM Payment pay
JOIN Orders o ON pay.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id;

-- Query 3: total paid per customer 
SELECT c.name AS customer, SUM(pay.amount) AS total_paid
FROM Payment pay
JOIN Orders o ON pay.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
GROUP BY c.name;

-- Query 4: order total, amount paid and balance per order 
SELECT o.order_id, c.name AS customer, t.order_total,
       IFNULL(p.paid, 0) AS paid,
       t.order_total - IFNULL(p.paid, 0) AS balance
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN (SELECT order_id, SUM(quantity * price_at_order) AS order_total
      FROM OrderItem GROUP BY order_id) t ON t.order_id = o.order_id
LEFT JOIN (SELECT order_id, SUM(amount) AS paid
           FROM Payment GROUP BY order_id) p ON p.order_id = o.order_id;

-- Query 5: ingredient cost and margin per product 
SELECT p.name AS product, p.price,
       ROUND(SUM(ri.amount_ml * i.cost / i.quantity_in_stock), 2) AS ingredient_cost,
       ROUND(p.price - SUM(ri.amount_ml * i.cost / i.quantity_in_stock), 2) AS margin
FROM Product p
JOIN Recipe r ON r.product_id = p.product_id
JOIN RecipeIngredient ri ON ri.recipe_id = r.recipe_id
JOIN Ingredient i ON i.ingredient_id = ri.ingredient_id
GROUP BY p.product_id, p.name, p.price;

EXPLAIN
SELECT p.name AS product, p.price,
       ROUND(SUM(ri.amount_ml * i.cost / i.quantity_in_stock), 2) AS ingredient_cost,
       ROUND(p.price - SUM(ri.amount_ml * i.cost / i.quantity_in_stock), 2) AS margin
FROM Product p
JOIN Recipe r ON r.product_id = p.product_id
JOIN RecipeIngredient ri ON ri.recipe_id = r.recipe_id
JOIN Ingredient i ON i.ingredient_id = ri.ingredient_id
GROUP BY p.product_id, p.name, p.price;

-- Step 1: load test customers 
SET SESSION cte_max_recursion_depth = 100000;
INSERT INTO Customer (name, phone_number, address, customer_type)
WITH RECURSIVE seq AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT CONCAT('Test Customer ', n),
       CONCAT('080', LPAD(n, 8, '0')),
       CONCAT('Test Address ', n),
       IF(n % 10 = 0, 'wholesale', 'retail')
FROM seq;

SELECT COUNT(*) FROM Customer;

-- Step 2: BEFORE the index (no index on phone_number)
EXPLAIN SELECT * FROM Customer WHERE phone_number = '08000050000';
EXPLAIN ANALYZE SELECT * FROM Customer WHERE phone_number = '08000050000';

-- Step 3: create the index
CREATE INDEX idx_customer_phone ON Customer (phone_number);

-- Step 4: AFTER the index
EXPLAIN SELECT * FROM Customer WHERE phone_number = '08000050000';
EXPLAIN ANALYZE SELECT * FROM Customer WHERE phone_number = '08000050000';

DELETE FROM Customer WHERE customer_id > 4;
SELECT COUNT(*) FROM Customer;
