# Portfolio 4: NoSQL and Advanced Data Models

**Case study:** ZAARH Collections (see `portfolio-1-database-design/case-study.md`)
**NoSQL type:** document database (MongoDB on a free MongoDB Atlas cluster, using MongoDB Compass and mongosh)

## Contents

| File | Description |
|---|---|
| `portfolio4_mongo_data.js` | Creates the `zaarh_nosql` database and loads the sample data into four collections |
| `portfolio4_mongo_queries.js` | The six queries used as evidence: find, filter, embedded recipe, update, aggregation, and index |
| `nosql-analysis.md` | The document model, SQL comparison, indexing evidence, suitability for ZAARH, and limitations |
| `screenshots/` | Evidence from MongoDB Compass |

## What was done

1. **Document model** for ZAARH: `orders` (embedding the customer snapshot, items and payments), `products` (embedding the recipe), `customers` and `ingredients`.
2. **Implementation** on a free MongoDB Atlas cluster, loading the same sample data as the MySQL database.
3. **Queries:** a find with embedded data, a filter, an embedded-recipe lookup, an atomic stock update with `$inc`, and an aggregation (total paid per customer).
4. **Indexing:** the plan for a customer lookup changed from `COLLSCAN` to `IXSCAN` after creating an index.
5. **Analysis** of why a document model suits some of ZAARH's data and where the relational model is stronger.

## Evidence (screenshots folder)

| File | Shows |
|---|---|
| `p4-01-connected.png` | Compass connected to the Atlas cluster |
| `p4-02-insert.png` | The data script run in the shell, with the collection counts (customers 4, ingredients 7, orders 3, products 4) |
| `p4-03-collections.png` | The `zaarh_nosql` database with its four collections |
| `p4-04-find.png` | Q1: one order with its customer, items and payments in a single document |
| `p4-05-filter.png` | Q2: products priced above 7,000 |
| `p4-06-recipe.png` | Q3: a product with its embedded recipe |
| `p4-07-update.png` | Q4: stock reduced with `$inc` |
| `p4-08-aggregate.png` | Q5: total paid per customer |
| `p4-09-explain-before.png` | Q6: plan before the index (`COLLSCAN`) |
| `p4-10-index.png` | Q6: the index being created |
| `p4-11-explain-after.png` | Q6: plan after the index (`IXSCAN`) |

## How to reproduce

1. Create a free MongoDB Atlas cluster, add a database user, and allow your IP address.
2. Connect with MongoDB Compass and open the MongoDB shell.
3. Paste `portfolio4_mongo_data.js` into the shell (it can be re-run safely).
4. Run the queries in `portfolio4_mongo_queries.js` one block at a time. The stock update in Q4 uses `$inc`, so run it once only.

## Notes

- The Atlas connection string and database password are not stored in this repository.
- The MongoDB data is a separate copy of the sample data and is not synchronised with the MySQL database.
- The collection has only three orders, so the index evidence is the change of plan and not a timing difference.
