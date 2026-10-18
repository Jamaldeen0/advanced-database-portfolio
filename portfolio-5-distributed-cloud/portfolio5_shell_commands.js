db = db.getSiblingDB("zaarh_nosql");

// B1: cluster topology. 
db.hello()

// B2: write with a majority write concern 
db.orders.insertOne(
  { _id: "replication-test", testOrder: true, orderDate: new Date(),
    customer: { name: "Replication Test", type: "retail" }, items: [], payments: [] },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
)

// B3: read the same document from a secondary node 
db.getMongo().setReadPref("secondary")
db.orders.find({ testOrder: true })

// B4: clean up and return to reading from the primary.
db.getMongo().setReadPref("primary")
db.orders.deleteOne({ _id: "replication-test" })
db.orders.countDocuments()
