# Portfolio 2: Query Processing and Optimisation

**Case study:** ZAARH Collections (see `portfolio-1-database-design/case-study.md`)
**DBMS used:** MySQL 8.0 with MySQL Workbench

## Contents

| File | Description |
|---|---|
| `portfolio2_queries.sql` | All queries, the `EXPLAIN` statements, the indexing experiment and the clean-up |
| `performance-analysis.md` | Before and after comparison of the indexing experiment, with trade-offs and limitations |
| `screenshots/` | Evidence from MySQL Workbench |

## What was done

1. **Five business queries** over the ZAARH database: a filter, a three-table join, an aggregate with `GROUP BY`, a balance query using subqueries, and a cost and margin query across the production chain (Product, Recipe, RecipeIngredient, Ingredient).
2. **Execution plan** (`EXPLAIN`) of the production-cost query: every join uses a primary key or foreign key index (`eq_ref` and `ref`).
3. **Indexing experiment:** 300,004 test customers were loaded, a phone number lookup was timed with and without an index on `Customer.phone_number`, using `EXPLAIN` and `EXPLAIN ANALYZE`. The lookup changed from a full table scan (about 784 ms) to an index lookup (about 0.038 ms).
4. **Clean-up:** the test customers were deleted, leaving the original 4 sample customers.

## Evidence (screenshots folder)

| File | Shows |
|---|---|
| `p2-01-filter.png` | Query 1: products over 7000 |
| `p2-02-join.png` | Query 2: payments with customer names |
| `p2-03-aggregate.png` | Query 3: total paid per customer |
| `p2-04-balance.png` | Query 4: order total, paid and balance |
| `p2-05-cost.png` | Query 5: ingredient cost and margin per product |
| `p2-06-explain-q5.png` | Execution plan of Query 5 |
| `p2-07-bulk-load.png` | 300,004 customers after the test load |
| `p2-08-explain-before.png` | Plan before the index: full scan (`ALL`) |
| `p2-09-analyze-before.png` | `EXPLAIN ANALYZE` before the index (about 784 ms) |
| `p2-10-create-index.png` | The index being created |
| `p2-11-explain-after.png` | Plan after the index: `ref` using `idx_customer_phone` |
| `p2-12-analyze-after.png` | `EXPLAIN ANALYZE` after the index (about 0.038 ms) |

## How to reproduce

1. Build the database with `portfolio-1-database-design/zaarh_schema.sql` and `zaarh_data.sql`.
2. Run the sections of `portfolio2_queries.sql` one at a time in MySQL Workbench.

## Notes

- Query 5 assumes `Ingredient.cost` is the cost of the whole stock quantity, so cost per ml is `cost / quantity_in_stock`. Packaging is out of scope.
- The 300,004 row count is because the 100,000-row load was accidentally run three times; the results are consistent for that table size.
- Timings come from single runs and are approximate.
