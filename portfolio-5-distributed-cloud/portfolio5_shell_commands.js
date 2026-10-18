// ZAARH Collections: Portfolio 5, Distributed and Cloud Database (MongoDB Atlas)
// Run in the MONGOSH shell in MongoDB Compass, connected to the Atlas cluster,
// after running portfolio4_mongo_data.js. Paste one block at a time.
// Do not store the Atlas connection string or password in this file.

db = db.getSiblingDB("zaarh_nosql");

// B1: cluster topology. Shows the replica set name, the three member hosts, and which one is the primary.
db.hello()
// Expect: setName 'atlas-...-shard-0', a hosts list of three addresses, a primary address, isWritablePrimary: true

// B2: write with a majority write concern (run once; the fixed _id makes a second run fail safely).
// w: "majority" means the write is confirmed only after most nodes have it.
db.orders.insertOne(
  { _id: "replication-test", testOrder: true, orderDate: new Date(),
    customer: { name: "Replication Test", type: "retail" }, items: [], payments: [] },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
)
// Expect: acknowledged: true, insertedId: 'replication-test'

// B3: read the same document from a secondary node (shows the write was replicated).
db.getMongo().setReadPref("secondary")
db.orders.find({ testOrder: true })
// Expect: the test order. If empty, wait a few seconds and run the find again.

// B4: clean up and return to reading from the primary.
db.getMongo().setReadPref("primary")
db.orders.deleteOne({ _id: "replication-test" })
db.orders.countDocuments()
// Expect: 3
