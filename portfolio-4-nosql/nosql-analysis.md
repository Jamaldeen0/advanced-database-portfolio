# Portfolio 4: NoSQL Model and Suitability Analysis

## Choice of NoSQL type

A **document database** was chosen, using MongoDB on a free MongoDB Atlas cluster, managed through MongoDB Compass and its built-in shell (mongosh). A document database stores each record as a JSON-like document, so data that is always read together can be kept inside one document instead of being split across tables and joined.

## The ZAARH document model

| Collection | Each document holds | Design decision |
|---|---|---|
| `orders` | order date, a **snapshot of the customer** (name and type), an array of **items** (product, quantity, price at order), and an array of **payments** | An order is always read as a whole, so its items and payments are embedded |
| `products` | name, size, price, stock, and its **recipe** (an array of ingredient and amount in ml) | A product and its recipe are always used together, so the one-to-one relationship becomes embedding |
| `customers` | name, phone, address, type | Managed on its own |
| `ingredients` | name, cost, stock in ml | Managed on its own |

The guiding rule was: embed what is read together, and keep separate what is managed on its own.

Example order document:

```json
{
  "orderDate": "2026-10-03T10:15:00Z",
  "customer": { "name": "Bright Scents", "type": "wholesale" },
  "items": [ { "product": "Pearl Whisper", "quantity": 10, "priceAtOrder": 5500 } ],
  "payments": [
    { "amount": 30000, "date": "2026-10-03T10:20:00Z" },
    { "amount": 25000, "date": "2026-10-10T09:00:00Z" }
  ]
}
```

## How the model maps to the relational design

| Relational design (MySQL) | Document design (MongoDB) |
|---|---|
| `Orders`, `OrderItem` and `Payment` tables | one `orders` document with `items` and `payments` arrays |
| `Recipe` and `RecipeIngredient` tables | a `recipe` array inside each `products` document |
| junction tables to resolve many-to-many | not needed, because arrays are embedded |
| foreign keys | not enforced; documents refer to each other by name |
| `price_at_order` column | `priceAtOrder` field (same idea: a deliberate snapshot) |

## Queries and their SQL equivalents

| Task | MongoDB | SQL |
|---|---|---|
| Orders for one customer, with items and payments | `db.orders.find({ "customer.name": ... })`, one read | joins across Customer, Orders, OrderItem and Payment |
| Products over 7,000 | `find({ price: { $gt: 7000 } })` | `WHERE price > 7000` |
| A product's recipe | `findOne({ name: ... })`, recipe embedded | join across Product, Recipe, RecipeIngredient and Ingredient |
| Reduce stock | `updateOne(..., { $inc: { stock: -2 } })` | `UPDATE ... SET quantity_in_stock = quantity_in_stock - 2` |
| Total paid per customer | `aggregate([ $unwind, $group, $sort ])` | `SUM(...) ... GROUP BY` |

The total paid per customer (Bright Scents 55,000, Amaka Obi 16,000, Tunde Bello 14,500) matches the result of the equivalent SQL query in Portfolio 2.

## Indexing evidence

Before the index, the plan for finding an order by customer name was a full collection scan (`COLLSCAN`). After `createIndex({ "customer.name": 1 })`, the plan used the index (`IXSCAN` on `customer.name_1`). The collection holds only three orders, so no timing difference can be shown. The evidence is the change of plan, and at larger scale it would behave like the Portfolio 2 experiment, where an index took a lookup from about 784 ms to about 0.038 ms.

## Why a document model suits ZAARH

- **Orders are read as a unit.** Showing an order with its customer, items and payments is one read of one document.
- **Recipes belong to products.** A scent formula is always used with its product, so embedding it matches how it is used.
- **Flexible structure.** New product attributes or wholesale terms can be added to some documents without changing a table definition.
- **Cloud and replication ready.** The Atlas cluster is a replica set, which supports Portfolio 5.

## Where it is weaker

- **Duplicated data.** The customer's name and type are copied into each order. This is right for history (an order keeps the details it was placed with), but a corrected customer name would not change old orders.
- **No foreign keys.** Nothing stops an order referring to a product that does not exist, and recipes refer to ingredients by name, so renaming an ingredient means updating every recipe that uses it.
- **Cross-collection reports are harder.** For example, the ingredient cost of a product needs a lookup between `products` and `ingredients`, which SQL expresses more naturally with joins.
- **Consistency across documents.** Updating a single document is atomic in MongoDB. Changes that span several documents (an order plus stock) need a multi-document transaction, which MongoDB supports on replica sets such as Atlas. This was not demonstrated here.

## Conclusion

For ZAARH as it is now, a sole-operator business with a small, well-structured data set, the relational MySQL design is fully adequate and gives stronger integrity. The document model is a good fit for how orders and recipes are read, and it would suit a growing business with a web or mobile application, changing product attributes and heavier read traffic. The two models are best seen as alternatives for different needs and not as a replacement of one by the other.

## Limitations

- The MongoDB data is a separate copy of the sample data. It is not synchronised with the MySQL database.
- Stock in the MongoDB `products` collection is independent of stock in MySQL.
- Only a few documents were used, so no performance comparison was possible.
- The Atlas connection string and database password are not stored in the repository.
