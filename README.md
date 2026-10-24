# MIT 8103 Advanced Database Systems: Individual Practical Database Portfolio

- **Student:** Jamaldeen Olajide Sulaiman
- **Student ID:** 301917084
- **Programme:** Master of Information Technology, 2026/2027 session, First Semester Continuous Assessment
- **Case study:** ZAARH Collections, an early-stage perfume oil business in Nigeria

## Case study

ZAARH Collections blends concentrated oils to create scents, which are sold as finished perfume oil products to retail and wholesale customers. The sole user of the database is the business owner. The database stores customers, products, orders and order items, payments, scent recipes and raw ingredients. The full statement is in `portfolio-1-database-design/case-study.md`.

## Repository structure

| Folder | Portfolio | Content |
|---|---|---|
| `portfolio-1-database-design/` | Portfolio 1: Database Design and Modelling | Case study, ER diagram, MySQL schema and sample data, normalisation (3NF), screenshots |
| `portfolio-2-query-optimisation/` | Portfolio 2: Query Processing and Optimisation | Five business queries, execution plans, an indexing experiment on 300,004 rows, performance analysis |
| `portfolio-3-transactions-concurrency/` | Portfolio 3: Transactions and Concurrency | Commit, rollback, a lost-update demonstration and its fix, isolation levels |
| `portfolio-4-nosql/` | Portfolio 4: NoSQL and Advanced Data Models | MongoDB document model, data, queries, index evidence, suitability analysis |
| `portfolio-5-distributed-cloud/` | Portfolio 5: Distributed and Cloud Database | MongoDB Atlas replica set evidence, availability, consistency, sharding discussion |

Each folder has its own `README.md` explaining the files, how the work was done, and what each screenshot shows.

## Tools used

- MySQL 8.0 and MySQL Workbench (Portfolios 1 to 3)
- MongoDB Atlas (free tier, AWS Paris, 3-node replica set), MongoDB Compass and mongosh (Portfolios 4 and 5)
- GitHub, with commits made progressively as each portfolio was finished

## How to reproduce

1. **MySQL:** run `portfolio-1-database-design/zaarh_schema.sql`, then `zaarh_data.sql`. The scripts in Portfolios 2 and 3 run against that database.
2. **MongoDB:** create a free Atlas cluster, connect with Compass, and run `portfolio-4-nosql/portfolio4_mongo_data.js` in the MongoDB shell.

## Notes

- The sample data is invented, except the ingredient costs, which are based on real ZAARH inventory costs.
- Database credentials and connection strings are not stored in this repository.
- AI use is declared in the submitted documentation, as the brief requires.
