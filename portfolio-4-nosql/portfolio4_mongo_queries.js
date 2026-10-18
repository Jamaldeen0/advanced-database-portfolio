// ZAARH Collections: Portfolio 4, MongoDB queries (mongosh)
// Run in the MONGOSH shell in MongoDB Compass, after running portfolio4_mongo_data.js.
// Paste one block at a time. Q4 changes data, so run it once only.

db = db.getSiblingDB("zaarh_nosql");

// Q1: all orders for one customer (one read; SQL needed joins across 4 tables)
db.orders.find({ "customer.name": "Bright Scents" })
// Expect: order 2, with its item and both payments inside the same document

// Q2: products priced above 7000 (SQL: WHERE price > 7000)
db.products.find({ price: { $gt: 7000 } }, { name: 1, price: 1, _id: 0 })
// Expect: Crimson Veil 8000, Midnight Sultan 7500

// Q3: a product's recipe (the recipe is embedded in the product; SQL needed a 4-table join)
db.products.findOne({ name: "Crimson Veil" }, { name: 1, recipe: 1, _id: 0 })
// Expect: Baccarat Rouge 6.0 ml and White Musk 1.5 ml

// Q4: update stock. $inc subtracts from the stored value, so run once only.
db.products.updateOne({ name: "Crimson Veil" }, { $inc: { stock: -2 } });
db.products.find({ name: "Crimson Veil" }, { name: 1, stock: 1, _id: 0 })
// Expect: stock 18
// Put it back (once only):
db.products.updateOne({ name: "Crimson Veil" }, { $inc: { stock: 2 } })

// Q5: total paid per customer (SQL: SUM(...) ... GROUP BY)
db.orders.aggregate([
  { $unwind: "$payments" },
  { $group: { _id: "$customer.name", totalPaid: { $sum: "$payments.amount" } } },
  { $sort: { totalPaid: -1 } }
])
// Expect: Bright Scents 55000, Amaka Obi 16000, Tunde Bello 14500

// Q6: indexing. The plan before the index is a collection scan (COLLSCAN).
db.orders.find({ "customer.name": "Bright Scents" }).explain("executionStats").queryPlanner.winningPlan

// Create the index
db.orders.createIndex({ "customer.name": 1 })
// Expect: customer.name_1

// The plan after the index uses an index scan (IXSCAN)
db.orders.find({ "customer.name": "Bright Scents" }).explain("executionStats").queryPlanner.winningPlan
