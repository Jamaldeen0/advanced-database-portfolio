# Portfolio 2: Performance Analysis

## Experiment

**Question:** how much does an index speed up looking up a customer by phone number?

**Setup:** the `Customer` table was filled with test rows until it held 300,004 customers (4 real sample rows plus 300,000 generated ones; the 100,000-row load script was run three times by mistake, so each generated phone number appears three times). `Customer.phone_number` has no index by default, because only primary keys and foreign keys are indexed automatically.

**Query tested:**

```sql
SELECT * FROM Customer WHERE phone_number = '08000050000';
```

## Results

| | Before the index | After `idx_customer_phone` |
|---|---|---|
| Access type (`EXPLAIN`) | `ALL` (full table scan) | `ref` (index lookup) |
| Key used | none (`NULL`) | `idx_customer_phone` |
| Rows read | 300,004 (whole table) | 3 (the matching rows only) |
| Optimiser cost estimate | about 30,203 | about 1.05 |
| Actual time (`EXPLAIN ANALYZE`) | about 784 ms | about 0.038 ms |

## Analysis

Without an index, MySQL had no way to find a phone number except by reading every row and testing it, so the plan showed `type = ALL` and the query read all 300,004 customers in about 784 ms. After `CREATE INDEX idx_customer_phone ON Customer (phone_number)`, the plan changed to `type = ref` using the new index. MySQL jumped directly to the 3 matching rows, and the query finished in about 0.038 ms. That is roughly 20,000 times faster, and the optimiser's own cost estimate fell from about 30,203 to about 1.05.

## Trade-offs

- The index took about 8.3 seconds to build on 300,004 rows.
- It uses extra disk space.
- Every future `INSERT`, `UPDATE` or `DELETE` on `Customer` must also update the index, so writes become slightly slower.
- An index is worth creating on a column that is searched often and has many distinct values. It would add little on a column such as `customer_type`, which has only two values.

## Other observations

- The five business queries already use indexes on every join (`eq_ref` and `ref` in the plan for the production-cost query), because the primary keys and foreign keys from the Portfolio 1 design are indexed automatically. On a 4-row table, a full scan of `Product` is the correct choice, since the query needs every row anyway.

## Limitations

- Each timing is from a single run, and the figures vary slightly between runs and with caching, so they should be read as approximate.
- The test data is artificial, with each phone number repeated three times. With unique numbers, the indexed lookup would read 1 row.
