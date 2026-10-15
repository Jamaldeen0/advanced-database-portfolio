# Portfolio 3: Transactions and Concurrency

**Case study:** ZAARH Collections (see `portfolio-1-database-design/case-study.md`)
**DBMS used:** MySQL 8.0 with MySQL Workbench (InnoDB tables)

## Contents

| File | Description |
|---|---|
| `portfolio3_transactions.sql` | All transaction, concurrency and isolation scripts, with the session (A or B) for each step |
| `concurrency-analysis.md` | Explanation of the results, the fix for the lost update, isolation levels, and limitations |
| `screenshots/` | Evidence from MySQL Workbench |

## What was done

1. **Commit:** a complete order (order, item, payment and stock reduction) saved as one transaction.
2. **Rollback:** a stock change made inside a transaction and then undone.
3. **Concurrency problem:** two sessions selling the same product at the same time produced a lost update (stock of 13 instead of 10).
4. **Control mechanism:** subtracting from the stored value (`stock = stock - n`) under InnoDB row locking gave the correct result (10).
5. **Isolation:** under `REPEATABLE READ` a second session could not see another session's uncommitted change; under `READ UNCOMMITTED` it could (a dirty read).

## Evidence (screenshots folder)

| File | Shows |
|---|---|
| `p3-01-before.png` | Crimson Veil stock before the order (20) |
| `p3-02-commit.png` | The order transaction and `COMMIT` |
| `p3-03-after-commit.png` | Order, item, payment and new stock saved together |
| `p3-04-before-rollback.png` | Stock changed inside an open transaction (25) |
| `p3-05-after-rollback.png` | Stock back to 30 after `ROLLBACK` |
| `p3-06-A-reads.png` | Session A reads stock 15 |
| `p3-07-B-reads.png` | Session B also reads 15, before A saves |
| `p3-08-A-commits.png` | Session A writes 12 and commits |
| `p3-09-B-commits.png` | Session B writes 13 and commits |
| `p3-10-lost-update.png` | Final stock 13 instead of 10 (lost update) |
| `p3-11-A-reads.png` | Fix: Session A reads 15 |
| `p3-12-B-reads.png` | Fix: Session B reads 15 |
| `p3-13-A-commits.png` | Fix: Session A subtracts 3 and commits |
| `p3-14-B-commits.png` | Fix: Session B subtracts 2 and commits |
| `p3-15-fixed.png` | Fix: final stock 10 (correct) |
| `p3-16-isolation-level.png` | Default isolation level: `REPEATABLE-READ` |
| `p3-17-A-uncommitted.png` | Session A changes stock to 5 without committing |
| `p3-18-B-sees-15.png` | Session B still sees 15 |
| `p3-19-B-read-uncommitted.png` | Session B set to `READ-UNCOMMITTED` |
| `p3-20-A-uncommitted-again.png` | Session A changes stock to 5 again, uncommitted |
| `p3-21-B-dirty-read.png` | Session B sees the uncommitted 5 (dirty read) |
| `p3-22-B-after-rollback.png` | After Session A rolls back, Session B sees 15 again |

## How to reproduce

1. Build the database with the Portfolio 1 scripts.
2. Open two separate connection tabs in MySQL Workbench (Session A and Session B).
3. Run the steps in `portfolio3_transactions.sql` in the order shown, once each. The relative updates in Part 3B subtract again every time they are run.

## Notes

- Concurrency is simulated with two connections controlled by hand, not real simultaneous load.
- The order placed in Part 1 stays in the live database, so the live data differs slightly from `zaarh_data.sql`. Midnight Sultan stock was reset to 15 after the experiments.
