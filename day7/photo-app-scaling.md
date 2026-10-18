# SnapShare Scaling Plan

## Assumptions and estimates

- There are 10 million registered users, and 10% are active each day: **1 million daily active users (DAU)**.
- Each daily active user uploads one photo and views 50 feed pages per day.
- The service is available 24 hours a day, 365 days a year, and activity is spread evenly for average-rate estimates.
- A peak rate is five times the average feed-view rate.
- MB and KB use decimal units: 1 MB = 1,000,000 bytes and 1 KB = 1,000 bytes.
- Each upload stores one 2 MB original and one 50 KB thumbnail. Storage estimates exclude backups, replicas, metadata, and any compression or deletion.

### Daily and per-second rates

- **Uploads:** 1,000,000 photos per day, or 1,000,000 / 86,400 = **about 11.6 uploads per second on average**.
- **Feed views:** 1,000,000 users × 50 pages = 50,000,000 pages per day, or 50,000,000 / 86,400 = **about 579 feed views per second on average**.
- **Peak feed views:** 579 × 5 = **about 2,894 feed views per second**.

### Annual photo storage

- **Original photos:** 1,000,000 × 365 × 2 MB = 730,000,000 MB = **730 TB per year**.
- **Thumbnails:** 1,000,000 × 365 × 50 KB = 18,250,000,000 KB = **18.25 TB per year**.
- **Total:** approximately **748.25 TB per year** for originals and thumbnails, before storage overhead or copies.

## Read or write heavy?

SnapShare is **read-heavy**: users view 50 feed pages for each photo uploaded, so feed and photo delivery should scale independently from uploads. The database read replica, cache, and CDN take pressure off the primary database and app servers; the primary database still handles writes such as photo metadata and follows.

## Architecture

```text
[Clients] -- API requests --> [Load Balancer] --> [App Servers]
[App Servers] -- metadata writes --> [Primary DB] -- replication --> [Read Replica]
[App Servers] -- feed lookup --> [Cache] -- cache miss --> [Read Replica]
[Read Replica] -- feed data --> [App Servers]
[App Servers] -- signed upload URL --> [Clients]
[Clients] -- original photo upload --> [Object Storage]
[App Servers] -- thumbnail job --> [Queue] --> [Thumbnail Worker]
[Thumbnail Worker] -- read original / write thumbnail --> [Object Storage]
[Thumbnail Worker] -- ready status --> [Primary DB]
[Object Storage] -- photo origin --> [CDN] --> [Clients]
```

The app server returns a signed upload URL to the client, which uploads the original directly to object storage:

```text
Clients -- original photo (signed URL) --> Object Storage
```

## What each component solves

- **CDN:** Serves cached photo files from locations near users, reducing image-delivery latency and origin traffic.
- **Load balancer:** Distributes incoming API requests across healthy app servers.
- **App servers:** Run the API and business logic without keeping user session state on a single server, so more servers can be added as demand grows.
- **Cache:** Keeps frequently requested feed data close to the app servers and reduces repeated database reads.
- **Primary database:** Reliably stores structured data such as users, follows, photo records, and upload status.
- **Read replica:** Serves database reads separately from the primary, increasing read capacity while the primary handles writes.
- **Object storage:** Holds the large original and thumbnail files durably without putting photo bytes in database rows.
- **Queue:** Holds thumbnail tasks so a temporary worker slowdown does not block photo uploads or lose the work.
- **Thumbnail worker:** Processes queued tasks in the background, creating smaller images for efficient feed delivery.

Photo files belong in object storage, while the database stores their IDs, owners, captions, and storage keys. This keeps large binary files out of database backups and queries and lets the CDN serve them efficiently.

## Photo upload flow

1. The client sends an upload request to the load balancer, which forwards it to an app server.
2. The app server authenticates the user, creates a pending photo record in the primary database, and returns a short-lived upload URL for object storage.
3. The client uploads the original photo directly to object storage using that URL, avoiding routing the large file through an app server.
4. After the upload succeeds, the client notifies the app server; the app server marks the photo as uploaded and puts a thumbnail job on the queue.
5. A thumbnail worker takes the job, reads the original from object storage, creates a 50 KB thumbnail, and saves it back to object storage.
6. The worker marks the photo as ready in the database; the app can then include it in feeds, and the CDN can cache and serve the thumbnail and original.

## Trade-offs

- **Direct object-storage uploads versus proxying uploads through app servers:** Direct uploads reduce app-server bandwidth and make large uploads easier to scale, but require short-lived upload URLs and careful authorization.
- **Asynchronous thumbnails versus waiting during upload:** A queue keeps uploads responsive and allows thumbnail work to scale separately, but a new photo may not have a thumbnail immediately if workers are delayed.
- **Read replicas and caches versus freshest data:** Replicas and cached feeds increase read capacity and reduce latency, but replication lag or stale cache entries can briefly hide a new photo or show an older feed.
- **Separate original and thumbnail files versus fewer stored copies:** Thumbnails make feed browsing faster and use less bandwidth, but add processing work and storage on top of each original.
