// ZAARH Collections: Portfolio 4, MongoDB (document model)
// Paste this whole script into the MONGOSH shell in MongoDB Compass.
// It can be run more than once: it drops and recreates the four collections each time.
// Data matches portfolio-1-database-design/zaarh_data.sql (customers, products, ingredients, orders 1 to 3).

db = db.getSiblingDB("zaarh_nosql");

db.customers.drop();
db.products.drop();
db.ingredients.drop();
db.orders.drop();

// Customers: managed on their own
db.customers.insertMany([
  { name: "Amaka Obi",     phone: "08011111111", address: "Lekki, Lagos", type: "retail" },
  { name: "Bright Scents", phone: "08022222222", address: "Ikeja, Lagos", type: "wholesale" },
  { name: "Tunde Bello",   phone: "08033333333", address: "Wuse, Abuja",  type: "retail" },
  { name: "Fatima Yusuf",  phone: "08044444444", address: "Kano",         type: "retail" }
]);

// Ingredients: managed on their own (stock in ml)
db.ingredients.insertMany([
  { name: "Baccarat Rouge", cost: 18000, stockMl: 100 },
  { name: "Black Oudh",     cost: 15000, stockMl: 100 },
  { name: "White Musk",     cost: 20000, stockMl: 100 },
  { name: "Sandal Oud",     cost: 15000, stockMl: 100 },
  { name: "Black Royal",    cost: 17000, stockMl: 100 },
  { name: "Icon",           cost: 12000, stockMl: 100 },
  { name: "Turkey Oud",     cost: 20000, stockMl: 100 }
]);

// Products: each product EMBEDS its recipe (always used together, one-to-one)
db.products.insertMany([
  { name: "Crimson Veil",    mlSize: 10, price: 8000, stock: 20,
    recipe: [ { ingredient: "Baccarat Rouge", amountMl: 6.0 }, { ingredient: "White Musk", amountMl: 1.5 } ] },
  { name: "Midnight Sultan", mlSize: 10, price: 7500, stock: 15,
    recipe: [ { ingredient: "Black Oudh", amountMl: 5.0 }, { ingredient: "Turkey Oud", amountMl: 2.0 } ] },
  { name: "Pearl Whisper",   mlSize: 10, price: 6500, stock: 30,
    recipe: [ { ingredient: "White Musk", amountMl: 6.5 }, { ingredient: "Icon", amountMl: 1.0 } ] },
  { name: "Golden Dune",     mlSize: 10, price: 7000, stock: 12,
    recipe: [ { ingredient: "Sandal Oud", amountMl: 5.5 }, { ingredient: "Black Royal", amountMl: 1.5 } ] }
]);

// Orders: each order EMBEDS a snapshot of the customer, its items and its payments
db.orders.insertMany([
  { orderDate: ISODate("2026-10-01T14:30:00Z"),
    customer: { name: "Amaka Obi", type: "retail" },
    items:    [ { product: "Crimson Veil", quantity: 2, priceAtOrder: 8000 } ],
    payments: [ { amount: 16000, date: ISODate("2026-10-01T14:35:00Z") } ] },

  { orderDate: ISODate("2026-10-03T10:15:00Z"),
    customer: { name: "Bright Scents", type: "wholesale" },
    items:    [ { product: "Pearl Whisper", quantity: 10, priceAtOrder: 5500 } ],
    payments: [ { amount: 30000, date: ISODate("2026-10-03T10:20:00Z") },
                { amount: 25000, date: ISODate("2026-10-10T09:00:00Z") } ] },

  { orderDate: ISODate("2026-10-05T16:45:00Z"),
    customer: { name: "Tunde Bello", type: "retail" },
    items:    [ { product: "Midnight Sultan", quantity: 1, priceAtOrder: 7500 },
                { product: "Golden Dune",     quantity: 1, priceAtOrder: 7000 } ],
    payments: [ { amount: 14500, date: ISODate("2026-10-05T16:50:00Z") } ] }
]);

// Check: document count in each collection
// Expected: customers 4, ingredients 7, orders 3, products 4
db.getCollectionNames().forEach(c => print(c + ": " + db[c].countDocuments()));
