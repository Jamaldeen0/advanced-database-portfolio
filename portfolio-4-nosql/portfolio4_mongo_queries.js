db = db.getSiblingDB("zaarh_nosql");

// Q1: all orders for one customer 
db.orders.find({ "customer.name": "Bright Scents" })

// Q2: products priced above 7000 
db.products.find({ price: { $gt: 7000 } }, { name: 1, price: 1, _id: 0 })
// Expect: Crimson Veil 8000, Midnight Sultan 7500

// Q3: a product's recipe 
db.products.findOne({ name: "Crimson Veil" }, { name: 1, recipe: 1, _id: 0 })

// Q4: update stock. 
db.products.updateOne({ name: "Crimson Veil" }, { $inc: { stock: -2 } });
db.products.find({ name: "Crimson Veil" }, { name: 1, stock: 1, _id: 0 })

db.products.updateOne({ name: "Crimson Veil" }, { $inc: { stock: 2 } })

// Q5: total paid per customer (SQL: SUM(...) ... GROUP BY)
db.orders.aggregate([
  { $unwind: "$payments" },
  { $group: { _id: "$customer.name", totalPaid: { $sum: "$payments.amount" } } },
  { $sort: { totalPaid: -1 } }
])

// Q6: indexing. 
db.orders.find({ "customer.name": "Bright Scents" }).explain("executionStats").queryPlanner.winningPlan

// Create the index
db.orders.createIndex({ "customer.name": 1 })
// Expect: customer.name_1

db.orders.find({ "customer.name": "Bright Scents" }).explain("executionStats").queryPlanner.winningPlan
