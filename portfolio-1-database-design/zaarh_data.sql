USE zaarh;

INSERT INTO Customer (name, phone_number, address, customer_type) VALUES
('Amaka Obi',     '08011111111', 'Lekki, Lagos', 'retail'),
('Bright Scents', '08022222222', 'Ikeja, Lagos', 'wholesale'),
('Tunde Bello',   '08033333333', 'Wuse, Abuja',  'retail'),
('Fatima Yusuf',  '08044444444', 'Kano',         'retail');

INSERT INTO Product (name, ml_size, price, quantity_in_stock) VALUES
('Crimson Veil',    10, 8000.00, 20),
('Midnight Sultan', 10, 7500.00, 15),
('Pearl Whisper',   10, 6500.00, 30),
('Golden Dune',     10, 7000.00, 12);

INSERT INTO Ingredient (name, cost, quantity_in_stock) VALUES
('Baccarat Rouge', 18000.00, 100.00),
('Black Oudh',     15000.00, 100.00),
('White Musk',     20000.00, 100.00),
('Sandal Oud',     15000.00, 100.00),
('Black Royal',    17000.00, 100.00),
('Icon',           12000.00, 100.00),
('Turkey Oud',     20000.00, 100.00);

INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2026-10-01 14:30:00'),
(2, '2026-10-03 10:15:00'),
(3, '2026-10-05 16:45:00');

-- Order 2 is a wholesale order
INSERT INTO OrderItem (order_id, product_id, quantity, price_at_order) VALUES
(1, 1, 2, 8000.00),
(2, 3, 10, 5500.00),
(3, 2, 1, 7500.00),
(3, 4, 1, 7000.00);

-- Order 2 is paid in two instalments
INSERT INTO Payment (order_id, amount, payment_date) VALUES
(1, 16000.00, '2026-10-01 14:35:00'),
(2, 30000.00, '2026-10-03 10:20:00'),
(2, 25000.00, '2026-10-10 09:00:00'),
(3, 14500.00, '2026-10-05 16:50:00');

INSERT INTO Recipe (product_id, name) VALUES
(1, 'Crimson Veil formula'),
(2, 'Midnight Sultan formula'),
(3, 'Pearl Whisper formula'),
(4, 'Golden Dune formula');

INSERT INTO RecipeIngredient (recipe_id, ingredient_id, amount_ml) VALUES
(1, 1, 6.00), (1, 3, 1.50),
(2, 2, 5.00), (2, 7, 2.00),
(3, 3, 6.50), (3, 6, 1.00),
(4, 4, 5.50), (4, 5, 1.50);
