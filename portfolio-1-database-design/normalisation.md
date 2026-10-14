# Normalisation: ZAARH Collections Database

## Summary

The ZAARH database (8 tables: Customer, Orders, OrderItem, Payment, Product, Recipe, RecipeIngredient, Ingredient) is in **Third Normal Form (3NF)**, with one deliberate, documented exception (`price_at_order`, explained below).

## First Normal Form (1NF)

A table is in 1NF when every column holds a single atomic value, there are no repeating groups, and every table has a primary key.

- Every table has a single-column primary key (`customer_id`, `order_id`, `order_item_id`, and so on).
- An order that contains several products is not stored as a list inside one cell. Each product on an order is its own row in `OrderItem`.
- A recipe that uses several oils is not stored as a list inside one cell. Each oil in a recipe is its own row in `RecipeIngredient`.
- A customer's details are split into separate columns (`name`, `phone_number`, `address`), not stored as one block of text.

## Second Normal Form (2NF)

A table is in 2NF when it is in 1NF and no non-key column depends on only part of a composite key.

- Every table uses a single-column surrogate primary key, so a partial dependency cannot occur.
- Facts that describe a pairing are stored on the junction table that represents the pairing: `quantity` and `price_at_order` on `OrderItem` (they describe one product on one order), and `amount_ml` on `RecipeIngredient` (it describes one oil in one recipe). They do not belong to either side alone.

## Third Normal Form (3NF)

A table is in 3NF when it is in 2NF and no non-key column depends on another non-key column.

- Customer details (name, phone, address, type) exist only in `Customer`. `Orders` stores only `customer_id`, not the customer's name or address.
- Product details (name, size, price, stock) exist only in `Product`. `OrderItem` stores only `product_id`.
- Ingredient details (name, cost, stock) exist only in `Ingredient`. `RecipeIngredient` stores only `ingredient_id`.

### Why Orders stores `customer_id` and not the name or address

- Names are not unique: two customers can share a name, so a name cannot identify a customer reliably. `customer_id` is unique to one customer.
- Details change. If a customer moves, the address is updated in one row of `Customer`. If the address were copied onto every order, each old order would need updating, and any one missed would leave the data inconsistent (an update anomaly).

## Resolving many-to-many relationships

| Relationship | Resolved by |
|---|---|
| Orders and Product (many-to-many) | `OrderItem` |
| Recipe and Ingredient (many-to-many) | `RecipeIngredient` |

Each junction table turns one many-to-many relationship into two one-to-many relationships.

## Other design decisions

- **Payment is its own table.** One order can be paid in several instalments, so payments cannot be a single column on `Orders`. This also gives the transactions work in Portfolio 3 a real case (an order and its payment succeeding or failing together).
- **Recipe is one-to-one with Product.** Enforced with a `UNIQUE` constraint on `Recipe.product_id`, so a product cannot have two competing formulas.
- **`customer_type` distinguishes retail from wholesale** customers within one table, because both are customers with the same attributes.
- **Packaging supplies were left out of scope.** They were not linked to any product, so removing the table affected no other table.

## Deliberate exception: `price_at_order`

`OrderItem.price_at_order` repeats information that also exists in `Product.price`. This is intentional. Prices change over time, and a past order must keep the price the customer actually paid. Storing the price at the time of sale keeps historical records accurate. Without it, raising a price would silently change the value of every past order. It is a recorded copy of a fact at a moment in time, not an accidental duplicate.

## Known limitation

`quantity_in_stock` in `Product` and `Ingredient` is not updated automatically when an order is placed. Keeping stock consistent with sales is handled with transactions in Portfolio 3.
