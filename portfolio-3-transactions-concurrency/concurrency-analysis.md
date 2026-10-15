# Portfolio 3: Transactions and Concurrency Analysis

## Why transactions matter for ZAARH

Placing an order changes several tables: a row in `Orders`, rows in `OrderItem`, a row in `Payment`, and a lower `quantity_in_stock` in `Product`. If only some of those changes happened, the records would contradict each other (for example, a paid order with the wrong stock). A transaction makes the group of changes atomic: all of them are saved, or none are. This also resolves the limitation noted in Portfolio 1, that stock does not update itself when an order is placed. All tables use InnoDB, MySQL's default engine, which supports transactions and row-level locking.

## Part 1: Commit

A complete order was placed inside one transaction: customer 4 (Fatima Yusuf) bought 2 Crimson Veil at 8,000 and paid 16,000. The transaction inserted the order, the order item and the payment, and reduced Crimson Veil stock from 20 to 18, then ended with `COMMIT`. A follow-up query joining all five tables showed the order, item, payment and the new stock together. `LAST_INSERT_ID()` was used so that the item and payment attach to the order that was just created.

## Part 2: Rollback

Inside an open transaction, Pearl Whisper stock was reduced by 5 (30 to 25) and the lower number was visible to that session. `ROLLBACK` then undid the change, and the stock read 30 again. This shows that nothing inside a transaction becomes permanent until `COMMIT`.

## Part 3A: The concurrency problem (lost update)

Two sessions represented two sales of Midnight Sultan at the same time. Both read the stock (15) before either saved. Session A sold 3 and wrote 12. Session B, still working from its earlier read of 15, sold 2 and wrote 13. The final stock was 13, but five were sold, so it should have been 10. Three bottles disappeared from the records, and no error or warning was shown. This is a lost update: the second write was based on stale data and overwrote the first.

## Part 3B: The fix

The same two sales were repeated, but each session subtracted from the value stored at the moment of writing (`quantity_in_stock = quantity_in_stock - n`) instead of writing a number it had calculated earlier. Starting again from 15, the sessions subtracted 3 and 2, and the final stock was 10, which is correct. InnoDB takes a lock on the row while it is being updated, so two updates to the same row cannot both apply at once; the second one is applied to the result of the first.

In this run Session A committed before Session B issued its update, so B did not visibly wait. The correct result comes from computing the new value from the current stored value, and the row lock is what guarantees this even if the two updates overlap in time.

For cases where the program must check the stock before deciding (for example, refusing a sale when too few remain), the row should be locked when it is read, using `SELECT ... FOR UPDATE` inside the transaction. This was not demonstrated here.

## Part 4: Isolation

| Session B's isolation level | What B saw while A had an uncommitted change (stock set to 5) |
|---|---|
| `REPEATABLE READ` (MySQL's default) | 15, the last committed value |
| `READ UNCOMMITTED` | 5, a value that A then rolled back |

Under the default level, a session sees only committed data, so uncommitted work is hidden. Under `READ UNCOMMITTED`, Session B read A's unsaved 5, which is a dirty read. After A rolled back, the stock was 15 again, so the 5 had never officially existed. If a program had acted on it (for example, telling a customer "only 5 left"), it would have acted on false information. Weaker isolation levels can be faster, but for stock and payments the default is the safer choice.

## Conclusions

- Use transactions for any action that changes more than one row or table, such as placing an order.
- Do not write a stock figure calculated from an earlier read. Update relative to the stored value, or lock the row when reading it.
- Keep the default isolation level for order and payment data.

## Limitations

- Concurrency was simulated with two Workbench connections run by hand, so the timing is controlled and is not real simultaneous load.
- The Part 1 order is still in the live database (order 4, and Crimson Veil stock of 18), so the live data differs slightly from `zaarh_data.sql`. Midnight Sultan stock was reset to 15 after the experiments.
- Only two isolation levels were demonstrated (`REPEATABLE READ` and `READ UNCOMMITTED`). `READ COMMITTED` and `SERIALIZABLE` were not tested.
- Deadlocks and `SELECT ... FOR UPDATE` waiting were not demonstrated.
