# Portfolio 5: Distributed and Cloud Database Analysis

## Deployment

The ZAARH document database from Portfolio 4 runs on a **MongoDB Atlas free-tier cluster** (`Cluster0`), hosted on **AWS in Paris (eu-west-3)**, running MongoDB **8.0.34**. It is a **replica set of 3 nodes**. Atlas provisions, patches and monitors the servers, so the business does not run its own database machine. The cluster is reached from MongoDB Compass over an encrypted connection using a connection string, and access is limited by an IP access list and a database user.

Free-tier limits seen on the cluster overview: 512 MB of storage (about 143 MB used, almost all of it Atlas's sample movie dataset, not ZAARH data), a limit of 500 connections, and **backups inactive**.

## Replication

In a replica set, one node is the **primary** and takes all writes, and the other two are **secondaries** that copy the primary's changes. Three pieces of evidence were collected:

1. `db.hello()` listed the three member hosts, the replica set name and the current primary.
2. A test order was written with `w: "majority"`, which means MongoDB confirms the write only after most of the nodes have it.
3. With the read preference set to `secondary`, the same test order could be read, showing the write had been copied to a secondary node. The test order was then deleted and the order count returned to 3.

## Availability

With three nodes, the cluster keeps working if one node fails: the remaining two hold an election and one secondary becomes the new primary automatically, and the connection string used by Compass finds the new primary. Losing two of three nodes would stop writes, because a majority is needed to elect a primary. **A failover was not tested**, because forcing one is not available on the free tier.

A different availability problem was met from the client side. When the home internet connection's public IP address changed, Atlas refused the connection, and Compass showed a TLS error that looked like a server fault. The cause was the IP access list, which only allows listed addresses. The fix was to add the new address. Allowing access from anywhere (`0.0.0.0/0`) would stop this recurring, but it widens exposure and is not suitable for a real business database. For a production system, a fixed address, a VPN, or private networking would be better.

**Backups are inactive on the free tier**, so a mistaken delete could not be recovered from the cluster. The recovery path here is the data script stored in the GitHub repository. A paid tier with backups would be needed for real use.

## Consistency

Reading and writing can be tuned:

| Setting | What it gives | ZAARH use |
|---|---|---|
| Read from the **primary** (default) | always the latest committed data | stock levels, payments, order confirmation |
| Read from a **secondary** | possibly slightly out of date (eventual consistency), spreads the read load | reports and dashboards, where a few seconds of delay does not matter |
| Write with `w: "majority"` | the write survives the loss of one node | orders and payments |

In the terms of the CAP theorem, a MongoDB replica set favours consistency over availability when the network splits: a minority group of nodes cannot elect a primary or accept writes. This suits money and stock records better than a design that accepts conflicting writes.

## Sharding (discussion only)

Sharding splits one large collection across several machines, each holding part of the data. It is not available on the free tier, so it was not set up. For ZAARH only `orders` could ever grow large enough to be a candidate, since customers, products and ingredients stay small. A suitable shard key would be a compound key such as customer plus order date. A key that only increases, such as the order date alone, would send every new write to the same shard, and a hashed key spreads writes evenly but makes range queries touch every shard. At ZAARH's current size a single replica set is more than enough, and sharding would add cost and complexity without benefit.

## Comparison with the MySQL design

| | MySQL (Portfolios 1 to 3) | MongoDB Atlas (Portfolios 4 and 5) |
|---|---|---|
| Where it runs | one local server on a laptop | managed cluster in the cloud |
| Copies of the data | one | three (replica set) |
| If the machine fails | the database is unavailable | another node takes over automatically |
| Backups | manual (scripts in GitHub) | inactive on the free tier |
| Replication option | MySQL supports source-replica replication, which was not set up here | built in |

## Security notes

- Connections are encrypted in transit.
- Access is restricted by the IP access list, and by a database user and password.
- The database user created by Atlas has the broad Atlas Admin role. For real use, a user limited to read and write on one database would follow least privilege.
- The connection string and password are not stored in the repository.

## Latency

The cluster is in Paris and the user is in Nigeria, so each request travels a long way. For a single user this is fine. For a customer-facing application, a region closer to the users would reduce delay where the chosen tier offers one.

## Recommendation for ZAARH

At its current size, a single-owner business does not need a cloud cluster, and the local MySQL database is enough. A replicated cloud database becomes worthwhile when the business takes orders online, needs to stay available around the clock, or has several people using it. In that case: keep stock and payment reads on the primary, use `w: "majority"` for orders, enable backups, use a restricted database user, and restrict network access to known addresses.

## Limitations

- The cluster is a free-tier, shared deployment with only a few documents of ZAARH data, so no load or performance testing was possible.
- Failover and sharding were explained but not demonstrated.
- The read from a secondary was a single check, not a measurement of replication delay.
- The MongoDB data is a separate copy of the sample data and is not synchronised with the MySQL database.
