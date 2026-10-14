# Portfolio 1: Database Design and Model
**Case study:** ZAARH Collections, an early-stage perfume oil business in Nigeria. 
**DBMS used:** MySQL 8.0 with MySQL Workbench.

## Contents

| File | Description |
|---|---|
| `case-study.md` | Description of the organisation, its users, the data stored and the operations supported |
| `zaarh_schema.sql` | Creates the `zaarh` database and its 8 tables, with primary keys, foreign keys and constraints |
| `zaarh_data.sql` | Inserts sample data into all 8 tables |
| `06-er-diagram.png` | ER diagram generated from the live database (Workbench reverse engineering) |
| `zaarh-model.mwb` | Editable Workbench model file for the diagram |
| `normalisation.md` | Normalisation explanation (1NF, 2NF, 3NF) and design decisions |
| `screenshots/` | Evidence of the database running in MySQL Workbench |

## Design summary

The database has 8 tables in two groups joined by `Product`:

- **Sales side:** `Customer`, `Orders`, `OrderItem`, `Payment`
- **Production side:** `Ingredient`, `Recipe`, `RecipeIngredient`

Key design choices:
- `OrderItem` and `RecipeIngredient` are junction tables that resolve many-to-many relationships.
- `Payment` is separate from `Orders` so that one order can be paid in several instalments.
- `Recipe.product_id` is `UNIQUE`, making Product to Recipe a one-to-one relationship.
- `OrderItem.price_at_order` stores the price at the time of sale, so past orders stay accurate if prices change.
- Money columns use `DECIMAL(10,2)`; oil quantities use `DECIMAL` because they are measured in millilitres.

## How to run

1. Open MySQL Workbench and connect to a local MySQL server.
2. Run `zaarh_schema.sql` to create the database and tables.
3. Run `zaarh_data.sql` to load the sample data (run it once only).
4. Run `USE zaarh; SHOW TABLES;` to confirm 8 tables exist.

## Evidence (screenshots folder)

| File | Shows |
|---|---|
| `screenshot 1.png` | All 8 tables created |
| `screenshot 2.png` | Structure of `Orders`, including the foreign key |
| `screenshot 3.png` | Structure of `OrderItem`, including its two foreign keys |
| `screenshot 4.png` | Sample data in `Product` |
| `screenshot 5.png` | Sample data in `Customer` (retail and wholesale) |

## Notes

- Customer, product, order and payment data are invented sample data. Ingredient costs are based on real ZAARH inventory costs.
- Backward integration (farmer relationships and offtake contracts) is out of scope.
- Stock quantities are not updated automatically when an order is placed. This is handled with transactions in Portfolio 3.
- Packaging supplies were originally designed as a ninth table and were removed from the scope.
