-- ZAARH Collections: Portfolio 3, Transactions and Concurrency
-- Run against the zaarh database created by portfolio-1-database-design/zaarh_schema.sql
-- Tables use InnoDB (the MySQL default), which supports transactions and row-level locking.
--
-- Parts 3 and 4 use TWO separate connections in MySQL Workbench:
--   Session A = the first connection tab, Session B = the second connection tab.
-- Run each step once, in the order shown. Do not rerun a step: the relative
-- UPDATEs in Part 3B subtract again every time they run.

USE zaarh;

-- ---------------------------------------------------------------
-- Part 1: COMMIT. A complete order is saved as one unit.
-- Fatima Yusuf (customer 4) buys 2 Crimson Veil at 8000 and pays 16000.
-- ---------------------------------------------------------------

-- Before: Crimson Veil stock is 20
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 1;

START TRANSACTION;
INSERT INTO Orders (customer_id) VALUES (4);
SET @new_order = LAST_INSERT_ID();
INSERT INTO OrderItem (order_id, product_id, quantity, price_at_order) VALUES (@new_order, 1, 2, 8000.00);
INSERT INTO Payment (order_id, amount) VALUES (@new_order, 16000.00);
UPDATE Product SET quantity_in_stock = quantity_in_stock - 2 WHERE product_id = 1;
COMMIT;

-- After: the order, item, payment and the new stock (18) are all saved together
SELECT o.order_id, c.name AS customer, p.name AS product,
       oi.quantity, pay.amount AS paid, p.quantity_in_stock AS stock_now
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN OrderItem oi ON oi.order_id = o.order_id
JOIN Product p ON oi.product_id = p.product_id
JOIN Payment pay ON pay.order_id = o.order_id
WHERE o.order_id = (SELECT MAX(order_id) FROM Orders);

-- ---------------------------------------------------------------
-- Part 2: ROLLBACK. A change is made and then undone.
-- ---------------------------------------------------------------

START TRANSACTION;
UPDATE Product SET quantity_in_stock = quantity_in_stock - 5 WHERE product_id = 3;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 3;  -- 25 inside the transaction

ROLLBACK;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 3;  -- back to 30

-- ---------------------------------------------------------------
-- Part 3A: LOST UPDATE (the concurrency problem)
-- Reset first (either session): stock of Midnight Sultan (product 2) = 15
-- ---------------------------------------------------------------
UPDATE Product SET quantity_in_stock = 15 WHERE product_id = 2;

-- Step 1, Session A:
START TRANSACTION;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Step 2, Session B (before A saves):
START TRANSACTION;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Step 3, Session A sells 3 and writes the number it worked out (15 - 3):
UPDATE Product SET quantity_in_stock = 12 WHERE product_id = 2;
COMMIT;

-- Step 4, Session B sells 2 and writes the number it worked out from its old read (15 - 2):
UPDATE Product SET quantity_in_stock = 13 WHERE product_id = 2;
COMMIT;

-- Step 5, either session: shows 13. Five were sold, so it should be 10. Three bottles were lost.
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;

-- ---------------------------------------------------------------
-- Part 3B: THE FIX. Update relative to the value currently stored.
-- Reset first (either session):
-- ---------------------------------------------------------------
UPDATE Product SET quantity_in_stock = 15 WHERE product_id = 2;

-- Step 1, Session A:
START TRANSACTION;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Step 2, Session B:
START TRANSACTION;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Step 3, Session A:
UPDATE Product SET quantity_in_stock = quantity_in_stock - 3 WHERE product_id = 2;
COMMIT;

-- Step 4, Session B:
UPDATE Product SET quantity_in_stock = quantity_in_stock - 2 WHERE product_id = 2;
COMMIT;

-- Step 5, either session: shows 10, the correct result
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;

-- Reset afterwards:
UPDATE Product SET quantity_in_stock = 15 WHERE product_id = 2;

-- ---------------------------------------------------------------
-- Part 4: ISOLATION. What one session can see of another's uncommitted work.
-- ---------------------------------------------------------------

-- 4A: the default level (REPEATABLE READ) hides uncommitted changes.

-- Session A: confirm the isolation level
SELECT @@transaction_isolation;                                                  -- REPEATABLE-READ

-- Session A: change the stock but do NOT commit
START TRANSACTION;
UPDATE Product SET quantity_in_stock = 5 WHERE product_id = 2;
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 5

-- Session B: cannot see A's uncommitted change
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Session A:
ROLLBACK;

-- 4B: READ UNCOMMITTED allows a dirty read.

-- Session B: weaken its isolation level
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT @@transaction_isolation;                                                  -- READ-UNCOMMITTED

-- Session A: change the stock again, still without committing
START TRANSACTION;
UPDATE Product SET quantity_in_stock = 5 WHERE product_id = 2;

-- Session B: sees A's uncommitted 5 (a dirty read)
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 5

-- Session A: undo the change
ROLLBACK;

-- Session B: the 5 never officially existed
SELECT product_id, name, quantity_in_stock FROM Product WHERE product_id = 2;   -- 15

-- Session B: restore the default isolation level
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;                                                  -- REPEATABLE-READ
