---
title: Understanding Heroku Postgres Data Caching
slug: understanding-postgres-data-caching
url: https://devcenter.heroku.com/articles/understanding-postgres-data-caching
description: How Heroku Postgres caches data.
---

Data caching in Postgres cannot be preallocated or guaranteed. Instead it can only be estimated and can vary widely depending on your workload. Heroku Postgres plans have a certain amount of System RAM, much of which is used for caching, but users may see slightly better or worse caching in their databases. A well designed application serves more than 99% of queries from cache. To learn more about how Postgres caches, read the discussion below.

## How does PostgreSQL cache data?

While Postgres does have a few settings that directly affect memory allocation for the purposes of caching, most of the cache that Postgres uses will be provided by the underlying operating system. Postgres, unlike most other database systems, makes aggressive use of the operating system’s page cache for a very large number of operations.

As an example, say we provision a server with 7.5GB of total system memory. Of these 7.5GB, some small portion will be used by the Operating System kernel, some smaller part of it will be used for other programs, including Postgres. The rest, measured to be between 80% and 95% of that, is caching of data by the operating system.

We have observed that the memory footprint of a Heroku Postgres instance’s operating system and other running programs is 500MB on average, and costs are mostly fixed regardless of plan size.

There are a few distinct ways in which Postgres allocates this bulk of memory, and the majority of it is typically left for the operating system to manage. Postgres manages a “Shared Buffer Cache”, which it allocates and uses internally to keep data and indexes in memory. This is usually configured to be about 25% of total system memory for a server running a dedicated Postgres instance, such as all Heroku Postgres instances. The rest of available memory is used by Postgres for two purposes: to cache your data and indexes on disk via the operating system page cache, and for internal operations or data structures.

Data that has been recently written to or read from disk passes through the operating system page cache and is therefore cached in memory. In doing so, reads are served from cache, leading to significantly reduced block device I/O operations and consequently higher throughput. However, there are a few Postgres operations that also use this memory, thus invalidating the cache. 

The most noteworthy here are certain kinds of internal operations done to fulfill queries such as internal in-memory quicksorts and hash tables or group by operations. Furthermore every join in a query can use a certain amount of memory dictated by a Postgres configuration setting called work_mem. Each of these operations has the potential to use memory that would otherwise be used for data and index caching. However, this is also a form of caching in the sense that it avoids having to read the same information from disk to do their work.

Beyond this, there are other operations that require memory, such as running VACUUM by the autovacuum daemon (or yourself) as well as all DDL operations. In the DDL category, it’s worth mentioning the creation of indexes, which tend to consume large amounts of memory, thus also using up memory available for data and index caches, albeit temporarily.

[Heroku Postgres plans](https://postgres.heroku.com/pricing) vary primarily by the amount of System RAM available. The best way to understand what plan is best for your workload is to try them. More information can be found on [this article](https://devcenter.heroku.com/articles/heroku-postgres-plans#standard-tier).

## What does having a cold cache mean

If for some reason you experience a service disruption on your production tier Heroku Postgres database you may receive a message that when your database comes back online you will have a "cold cache". When you see this there is underlying hardware affected and as a result your database will come back online on a new host where no data will have been cached. 

>callout
>If you periodically send reads to your follower the cache may already be warmed, thereby reducing the time for your cache to be performing at normal levels.

If you have a [follower](https://devcenter.heroku.com/articles/heroku-postgres-follower-databases) you can promote it when you see this instead of waiting for your database to become available on the new host.  